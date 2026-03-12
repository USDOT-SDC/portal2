#! /bin/bash

# log all outputs from user-data script
exec > >(tee /tmp/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# Exactly what version of code is being run
echo "config_version: ${config_version}"

# Echo to a custom log file since STDOUT is not captured
ECHO_FILE=/tmp/user-data-echo.log
echo_to_log() {
    echo "================================================================================"
    echo "    $1"
    echo "================================================================================"
    echo "$(date) - $1" >>$ECHO_FILE
}

# ensure that we can still use ssh keys to connect w/o a password
echo_to_log "Delete password for ec2-user:..."
passwd -d ec2-user
echo_to_log "Delete password for ec2-user: Done!"

# === Instance Setup ===
echo_to_log "Getting info from meta-data:..."
# Get instance ID
INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
echo_to_log "instance-id: $INSTANCE_ID "
# Get IP address
IP_ADDRESS=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
IFS=. read ip1 ip2 ip3 ip4 <<<"$IP_ADDRESS"
echo_to_log "IP Address: $IP_ADDRESS "
echo_to_log "Getting info from meta-data: Done!"

echo_to_log "Setting hostname to guacamole-$ip3-$ip4.${environment}.sdc.dot.gov:..."
hostnamectl set-hostname guacamole-$ip3-$ip4.${environment}.sdc.dot.gov
aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Name,Value=guacamole-$ip3-$ip4
echo_to_log "Setting hostname to guacamole-$ip3-$ip4.${environment}.sdc.dot.gov: Done!"

# === Installs ===
# PackageKit auto-starts at boot and holds its own DNF lock independently of the RPM lock.
# Stop it first, then wait for any remaining dnf process and the RPM lock to clear.
echo_to_log "Waiting for package manager lock:..."
systemctl stop packagekit 2>/dev/null || true
systemctl disable packagekit 2>/dev/null || true
while pgrep -x dnf > /dev/null 2>&1; do
    echo "dnf process running, waiting 5s..."
    sleep 5
done
while ! flock -n /var/lib/rpm/.rpm.lock true 2>/dev/null; do
    echo "RPM lock held, waiting 5s..."
    sleep 5
done
echo_to_log "Waiting for package manager lock: Done!"

echo_to_log "Installing EPEL:..."
# disable the subscription manager that we don't have a subscription for
sed -i '/enabled=/c\enabled=0' /etc/dnf/plugins/subscription-manager.conf

aws s3 cp s3://${terraform_bucket}/${epel_gpg_key} /tmp/RPM-GPG-KEY-EPEL
rpm --import /tmp/RPM-GPG-KEY-EPEL
rm -f /tmp/RPM-GPG-KEY-EPEL
aws s3 cp s3://${terraform_bucket}/${epel_rpm_key} /tmp/epel-release.rpm
dnf install -y /tmp/epel-release.rpm
rm -f /tmp/epel-release.rpm
dnf config-manager --set-enabled codeready-builder-for-rhel-9-rhui-rpms
# Flush stale DNF metadata and cache now that all repos are registered.
# Prevents [Errno 2] cache-path misses on subsequent installs.
dnf clean all
echo_to_log "Installing EPEL: Done!"
export JAVA_HOME=/usr/lib/jvm/java
export TOMCAT_HOME=/opt/tomcat
export GUACAMOLE_HOME=/opt/guacamole


# === Install Tomcat and Prerequisites ===
echo_to_log "Installing JDK:..."
dnf install -y java-25-openjdk-devel >/dev/null
echo_to_log "Installing JDK: Done!"

echo_to_log "Installing Tomcat:..."
mkdir -p $TOMCAT_HOME
aws s3 cp s3://${terraform_bucket}/${tomcat_key} /opt/apache-tomcat-${tomcat_version}.tar.gz
tar -xvzf /opt/apache-tomcat-${tomcat_version}.tar.gz --directory /opt >/dev/null
cp -r /opt/apache-tomcat-${tomcat_version}/* $TOMCAT_HOME/
yes | rm -rf /opt/apache-tomcat-${tomcat_version}
yes | rm /opt/apache-tomcat-${tomcat_version}.tar.gz

groupadd tomcat
useradd -s /bin/false -g tomcat -d $TOMCAT_HOME tomcat
chown -R tomcat:tomcat $TOMCAT_HOME
chmod o+x $TOMCAT_HOME/bin
echo_to_log "Installing Tomcat: Done!"

echo_to_log "Configure Tomcat Service:..."
cat <<EOF >/etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat ${tomcat_version} Server
After=syslog.target network.target

[Service]
Type=forking
User=tomcat
Group=tomcat

Environment="JAVA_HOME=$JAVA_HOME"
Environment="GUACAMOLE_HOME=$GUACAMOLE_HOME"
Environment="JAVA_OPTS=-Xms512m -Xmx512m -Djava.awt.headless=true"
Environment="CATALINA_HOME=$TOMCAT_HOME"
Environment="CATALINA_BASE=$TOMCAT_HOME"
Environment="CATALINA_PID=$TOMCAT_HOME/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=$TOMCAT_HOME/bin/startup.sh
ExecStop=$TOMCAT_HOME/bin/shutdown.sh

UMask=0007

RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF
echo === === === === tomcat.service === === === ===
cat /etc/systemd/system/tomcat.service
echo === === === === tomcat.service === === === ===
systemctl daemon-reload
systemctl start tomcat
systemctl status tomcat
echo_to_log "Configure Tomcat Service: Done!"

# === Install Guacamole and Prerequisites===
echo_to_log "Deploying Guacamole Client:..."
systemctl stop tomcat
aws s3 cp s3://${terraform_bucket}/${guac_war_key} $TOMCAT_HOME/webapps/guacamole.war
unzip $TOMCAT_HOME/webapps/guacamole.war -d $TOMCAT_HOME/webapps/guacamole/ >/dev/null
yes | rm $TOMCAT_HOME/webapps/guacamole.war
echo_to_log "Deploying Guacamole Client: Done!"

echo_to_log "chown/chcon the Tomcat dir:..."
chown -R tomcat:tomcat $TOMCAT_HOME
chcon -R system_u:object_r:usr_t:s0 $TOMCAT_HOME
echo_to_log "chown/chcon the Tomcat dir: Done!"

echo_to_log "Creating Guacamole Client property file:..."
mkdir -p $GUACAMOLE_HOME
cat <<EOF >$GUACAMOLE_HOME/guacamole.properties
guacd-hostname: localhost
guacd-port: 4822
guacd-ssl: false

extension-priority: header
http-auth-header: REMOTE_USER
http-request-param: authToken
cognito-web-key-url: https://${cognito_pool_endpoint}/.well-known/jwks.json

mysql-hostname: ${mariadb_address}
mysql-database: guacamole_db
mysql-username: guacamole_user
mysql-password: ${mariadb_password}
mysql-port: 3306
mysql-driver: mysql
mysql-ssl-mode: disabled
EOF
echo === === === === guacamole.properties === === === ===
cat $GUACAMOLE_HOME/guacamole.properties
echo === === === === guacamole.properties === === === ===
echo_to_log "Creating Guacamole Client property file: Done!"

echo_to_log "Guacamole Server and prerequisites:..."
dnf install guacd-${guac_version} -y
dnf install libguac-client-rdp -y
# dnf install libguac-client-vnc -y
dnf install xfreerdp -y
echo_to_log "Guacamole Server and prerequisites: Done!"

echo_to_log "Installing Guacamole extensions and MySQL Connector:..."
mkdir -p $GUACAMOLE_HOME/extensions
mkdir -p $GUACAMOLE_HOME/lib

GUACAMOLE_AUTH_JDBC_MYSQL_PATH=$GUACAMOLE_HOME/extensions/guacamole-auth-jdbc-mysql-${guac_version}.jar
aws s3 cp s3://${terraform_bucket}/${guac_auth_jdbc_mysql_key} $GUACAMOLE_AUTH_JDBC_MYSQL_PATH

GUACAMOLE_AUTH_HEADER_PATH=$GUACAMOLE_HOME/extensions/guacamole-auth-header-${guac_auth_header_version}.jar
aws s3 cp s3://${terraform_bucket}/${guac_auth_header_key} $GUACAMOLE_AUTH_HEADER_PATH

MYSQL_CONNECTOR_PATH=$GUACAMOLE_HOME/lib/mysql-connector-j-${mysql_connector_version}
aws s3 cp s3://${terraform_bucket}/${mysql_connector_key} $MYSQL_CONNECTOR_PATH.jar
echo_to_log "Installing Guacamole extensions and MySQL Connector: Done!"

echo_to_log "Creating guacd conf file:..."
cat <<EOF >$GUACAMOLE_HOME/guacd.conf
[server]
bind_host = localhost
bind_port = 4822

[daemon]
log_level = debug
EOF
echo === === === === guacd.conf === === === ===
cat $GUACAMOLE_HOME/guacd.conf
echo === === === === guacd.conf === === === ===
echo_to_log "Creating guacd conf file: Done!"

echo_to_log "Setting Tomcat as the owner of Guacamole configurations and configuring SElinux permissions:..."
chmod -R 755 $GUACAMOLE_HOME
chown -R tomcat:tomcat $GUACAMOLE_HOME
chcon -R system_u:object_r:usr_t:s0 $GUACAMOLE_HOME
chmod -R 755 $TOMCAT_HOME/webapps
chown -R tomcat:tomcat $TOMCAT_HOME/webapps
chcon -R system_u:object_r:usr_t:s0 $TOMCAT_HOME/webapps
setsebool -P httpd_can_network_connect 1
setsebool -P tomcat_can_network_connect_db 1
echo_to_log "Setting Tomcat as the owner of Guacamole configurations and configuring SElinux permissions: Done!"

echo_to_log "Remove other Tomcat webapps:..."
yes | rm -rf $TOMCAT_HOME/webapps/docs/
yes | rm -rf $TOMCAT_HOME/webapps/examples/
yes | rm -rf $TOMCAT_HOME/webapps/host-manager/
yes | rm -rf $TOMCAT_HOME/webapps/manager/
yes | rm -rf $TOMCAT_HOME/webapps/ROOT/
echo_to_log "Remove other Tomcat webapps: Done!"

echo_to_log "Hardening Tomcat for production:..."
# Disable the TCP shutdown listener — port 8005 is a remote attack surface
sed -i 's/port="8005" shutdown="SHUTDOWN"/port="-1" shutdown="DISABLED"/' $TOMCAT_HOME/conf/server.xml

# Remove Tomcat version string from the HTTP Server response header
sed -i 's|<Connector port="8080"|<Connector port="8080" server=" "|' $TOMCAT_HOME/conf/server.xml

# Strip Tomcat version and stack traces from all error pages (404, 500, etc.)
sed -i 's|</Host>|  <Valve className="org.apache.catalina.valves.ErrorReportValve" showReport="false" showServerInfo="false"/>\n      </Host>|' $TOMCAT_HOME/conf/server.xml

echo === === === === server.xml === === === ===
cat $TOMCAT_HOME/conf/server.xml
echo === === === === server.xml === === === ===
echo_to_log "Hardening Tomcat for production: Done!"

echo_to_log "Creating minimal ROOT webapp:..."
# Redirect bare HTTP hits to Guacamole instead of serving a blank 404
mkdir -p $TOMCAT_HOME/webapps/ROOT
cat <<'EOF' >$TOMCAT_HOME/webapps/ROOT/index.html
<!DOCTYPE html>
<html>
<head><meta http-equiv="refresh" content="0;url=/guacamole"></head>
<body></body>
</html>
EOF
chown -R tomcat:tomcat $TOMCAT_HOME/webapps/ROOT
echo_to_log "Creating minimal ROOT webapp: Done!"

echo_to_log "Configuring Firewall:..."
systemctl enable firewalld
systemctl start firewalld
# RHEL 9 on EC2 may bind eth0 to the 'drop' zone (FMS/Bigfix managed).
# Explicitly move eth0 to 'public' and set public as the default zone so
# subsequent --zone=public rules actually apply to inbound traffic.
firewall-cmd --set-default-zone=public
firewall-cmd --zone=public --change-interface=eth0
firewall-cmd --permanent --zone=public --add-port=8080/tcp
firewall-cmd --permanent --zone=public --add-port=443/tcp
firewall-cmd --permanent --zone=public --add-port=4822/tcp
firewall-cmd --permanent --zone=public --add-port=52311/tcp
firewall-cmd --permanent --zone=public --add-port=52311/udp
firewall-cmd --reload
echo === === === === firewalld config === === === ===
firewall-cmd --list-all
firewall-cmd --list-all --zone=drop
echo === === === === firewalld config === === === ===
echo_to_log "Configuring Firewall: Done!"

echo_to_log "Starting tomcat and guacd:..."
systemctl daemon-reload
systemctl start tomcat
systemctl enable tomcat
systemctl start guacd
systemctl enable guacd
sleep 10
systemctl restart tomcat
systemctl status -l tomcat guacd
echo_to_log "Starting tomcat and guacd: Done!"

# === Install Utilities and Other Housekeeping ===
echo_to_log "Installing MC:..."
dnf install -y mc
echo_to_log "Installing MC: Done!"

echo_to_log "Installing dnf automatic:..."
dnf install dnf-automatic -y
cat <<'EOF' >/etc/dnf/automatic.conf
[commands]
upgrade_type = security
download_updates = yes
apply_updates = yes
network_online = 60
EOF
echo === === === === automatic.conf === === === ===
cat /etc/dnf/automatic.conf
echo === === === === automatic.conf === === === ===
systemctl enable --now dnf-automatic.timer
echo_to_log "Installing dnf automatic: Done!"

echo_to_log "Setting up the disk monitor alert"
DISK_ALERT_SCRIPT_PATH="/usr/local/bin/disk-alert-linux.py"
# get the script
/usr/local/bin/aws s3 cp s3://${disk_alert_script_bucket}/${disk_alert_script_key} $DISK_ALERT_SCRIPT_PATH
# make it executable
chmod +x $DISK_ALERT_SCRIPT_PATH
# write out current crontab to temp file
crontab -l >current_crontab
# echo new cron into temp file
echo "0 2 * * * python3 $DISK_ALERT_SCRIPT_PATH" >>current_crontab
# install new cron file from temp file
crontab current_crontab
# remove the temp file
rm current_crontab
echo_to_log "Setting up the disk monitor alert: Done!"

# === Run a Full System Update ===
echo_to_log "Running System update:..."
dnf update -y
echo_to_log "Running System update: Done!"

# Reboot if a new kernel was installed
RUNNING_KERNEL=$(uname -r)
LATEST_KERNEL=$(rpm -q --last kernel | head -1 | awk '{print $1}' | sed 's/kernel-//')
if [ "$RUNNING_KERNEL" != "$LATEST_KERNEL" ]; then
    echo_to_log "Kernel updated ($RUNNING_KERNEL → $LATEST_KERNEL) — rebooting to apply..."
    echo_to_log "User Data Script Complete!"
    reboot
else
    echo_to_log "No kernel update — reboot not required."
    echo_to_log "User Data Script Complete!"
fi
