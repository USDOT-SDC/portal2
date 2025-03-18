#! /bin/bash

# log all outputs from user-data script
exec > >(tee /tmp/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# Exactly what version of code is being run
echo "config_version: ${config_version}"
echo "git_commit: ${git_commit}"

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
echo_to_log "Installing EPEL:..."
# disable the subscription manager that we don't have a subscription for
sed -i '/enabled=/c\enabled=0' /etc/yum/pluginconf.d/subscription-manager.conf

rpm --import http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-8
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf config-manager --set-enabled codeready-builder-for-rhel-8-rhui-rpms
dnf install epel-release -y
echo_to_log "Installing EPEL: Done!"
export JAVA_HOME=/usr/lib/jvm/java
export TOMCAT_HOME=/opt/tomcat
export GUACAMOLE_HOME=/opt/guacamole


# === Install Tomcat and Prerequisites ===
echo_to_log "Installing JDK:..."
dnf install -y java-21-openjdk-devel >/dev/null
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

echo_to_log "Copying Guacamole web.xml:..."
GUACAMOLE_WEB_XML_PATH=$TOMCAT_HOME/webapps/guacamole/WEB-INF/web.xml
aws s3 cp --recursive s3://${terraform_bucket}/${guac_web_xml_key} $GUACAMOLE_WEB_XML_PATH
echo_to_log "Copying Guacamole web.xml: Done!"

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

GUACAMOLE_AUTH_HEADER_PATH=$GUACAMOLE_HOME/extensions/guacamole-auth-header-0.9.14.jar
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
# TODO: Put this back after everything is dialed in
yes | rm -rf $TOMCAT_HOME/webapps/docs/
yes | rm -rf $TOMCAT_HOME/webapps/examples/
yes | rm -rf $TOMCAT_HOME/webapps/host-manager/
yes | rm -rf $TOMCAT_HOME/webapps/manager/
yes | rm -rf $TOMCAT_HOME/webapps/ROOT/
echo_to_log "Remove other Tomcat webapps: Done!"

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

# === Configure the Firewall ===
echo_to_log "Configuring Firewall:..."
systemctl stop firewalld
firewall-offline-cmd --zone=public --add-port=8080/tcp
firewall-offline-cmd --zone=public --add-port=443/tcp
firewall-offline-cmd --zone=public --add-port=4822/tcp
firewall-offline-cmd --zone=public --add-port=52311/tcp
firewall-offline-cmd --zone=public --add-port=52311/udp
sleep 2 # Add a 2-second delay
systemctl start firewalld
firewall-cmd --reload
echo === === === === firewalld config === === === ===
firewall-cmd --list-all
echo === === === === firewalld config === === === ===
echo_to_log "Configuring Firewall: Done!"

# === Run a Full System Update ===
echo_to_log "Running System update:..."
dnf update -y
echo_to_log "Running System update: Done!"

# ensure that we can still use ssh keys to connect w/o a password
echo_to_log "Delete password for ec2-user:..."
passwd -delete ec2-user
echo_to_log "Delete password for ec2-user: Done!"

echo_to_log "User Data Script Complete!"
