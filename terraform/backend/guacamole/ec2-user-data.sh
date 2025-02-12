#! /bin/bash
exec > >(tee /tmp/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# Echo to a custom log file since STDOUT is not captured
ECHO_FILE=/tmp/user-data-echo.log
echo_to_log() {
    echo "$(date) - === === === === $1 === === === ==="
    echo "$(date) - $1" >>$ECHO_FILE
}

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
rpm --import http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-8
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf config-manager --set-enabled codeready-builder-for-rhel-8-rhui-rpms
crb enable
dnf install epel-release -y
echo_to_log "Installing EPEL: Done!"

# === Install Tomcat and Prerequisites ===
echo_to_log "Installing JDK:..."
dnf install -y java-21-openjdk-devel
JAVA_HOME=/usr/lib/jvm/java
echo_to_log "Installing JDK: Done!"

echo_to_log "Installing Tomcat:..."
aws s3 cp s3://${terraform_bucket}/${tomcat_key} /opt/apache-tomcat-${tomcat_version}.tar.gz
cd /opt
tar -xvzf apache-tomcat-${tomcat_version}.tar.gz
mv apache-tomcat-${tomcat_version} /opt/tomcat
groupadd tomcat
useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
chown -R tomcat:tomcat /opt/tomcat
chmod o+x /opt/tomcat/bin
echo_to_log "Installing Tomcat: Done!"

echo_to_log "Configure Tomcat Service:..."
cat <<EOF >/etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat 10 Server
After=syslog.target network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=$JAVA_HOME"
Environment="JAVA_OPTS=-Xms512m -Xmx512m"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_BASE=/opt/tomcat"
PIDFile="/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

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
echo_to_log "Configure Tomcat Service: Done!"

# === Install Guacamole and Prerequisites===
echo_to_log "Deploying Guacamole Client:..."
systemctl stop tomcat
aws s3 cp s3://${terraform_bucket}/${guac_war_key} /opt/tomcat/webapps/guacamole.war
unzip /opt/tomcat/webapps/guacamole.war -d /opt/tomcat/webapps/guacamole/
yes | rm /opt/tomcat/webapps/guacamole.war
chown -R tomcat:tomcat /opt/tomcat
chcon -R system_u:object_r:usr_t:s0 /opt/tomcat
echo_to_log "Deploying Guacamole Client: Done!"

echo_to_log "Creating Guacamole Client property file:..."
GUACAMOLE_HOME=/etc/guacamole
mkdir -p $GUACAMOLE_HOME
cat <<EOF >$GUACAMOLE_HOME/guacamole.properties
guacd-hostname: 127.0.0.1
guacd-port: 4822
guacd-ssl: false

mysql-hostname: ${mariadb_endpoint}
mysql-database: guacamole_db
mysql-username: guacamole_user
mysql-password: ${mariadb_password}
mysql-port: 3306
mysql-driver: mariadb
mysql-ssl-mode: disabled

openid-authorization-endpoint: "https://usdot-sdc-dev.auth.us-east-1.amazoncognito.com/oauth2/authorize"
openid-jwks-endpoint: "https://cognito-idp.us-east-1.amazonaws.com/us-east-1_XrR5IDCuP/.well-known/jwks.json"
openid-issuer: "https://cognito-idp.us-east-1.amazonaws.com/us-east-1_XrR5IDCuP"
openid-client-id: 4binc5ifp081iu97i0dhb10q68
openid-redirect-uri: "https://guacamole.sdc-dev.dot.gov/guacamole"
openid-scope: "openid email phone profile"
EOF
echo === === === === guacamole.properties === === === ===
cat $GUACAMOLE_HOME/guacamole.properties
echo === === === === guacamole.properties === === === ===
echo_to_log "Creating Guacamole Client property file: Done!"

echo_to_log "Installing MariaDB Client:..."
# run the following for help
# curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | bash -s -- --help
curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | bash -s -- --os-type=rhel
dnf install MariaDB-shared -y
dnf install MariaDB-client -y
echo_to_log "Installing MariaDB Client: Done!"

echo_to_log "Guacamole Server and prerequisites:..."
dnf install guacd -y
dnf install libguac-client-rdp -y
dnf install libguac-client-vnc -y
dnf install xfreerdp -y
echo_to_log "Guacamole Server and prerequisites: Done!"

echo_to_log "Installing Guacamole extensions and MariaDB Java Client:..."
mkdir -p $GUACAMOLE_HOME/extensions
mkdir -p $GUACAMOLE_HOME/lib

GUACAMOLE_AUTH_JDBC_PATH=$GUACAMOLE_HOME/extensions/guacamole-auth-jdbc-${guac_version}
aws s3 cp s3://${terraform_bucket}/${guac_auth_jdbc_key} $GUACAMOLE_AUTH_JDBC_PATH.tar.gz
tar -xvzf $GUACAMOLE_AUTH_JDBC_PATH.tar.gz
# yes | rm $GUACAMOLE_AUTH_JDBC_PATH.tar.gz
cp $GUACAMOLE_AUTH_JDBC_PATH/mysql/guacamole-auth-jdbc-mysql-${guac_version}.jar $GUACAMOLE_HOME/extensions/

GUACAMOLE_AUTH_SSO_PATH=$GUACAMOLE_HOME/extensions/guacamole-auth-sso-${guac_version}
aws s3 cp s3://${terraform_bucket}/${guac_auth_sso_key} $GUACAMOLE_AUTH_SSO_PATH.tar.gz
tar -xvzf $GUACAMOLE_AUTH_SSO_PATH.tar.gz
# yes | rm $GUACAMOLE_AUTH_SSO_PATH.tar.gz
cp $GUACAMOLE_AUTH_SSO_PATH/mysql/guacamole-auth-sso-openid-${guac_version}.jar $GUACAMOLE_HOME/extensions/

MARIADB_JAVA_CLIENT_PATH=$GUACAMOLE_HOME/lib/mariadb-java-client-${mariadb_client_version}
aws s3 cp s3://${terraform_bucket}/${mariadb_client_key} $MARIADB_JAVA_CLIENT_PATH.jar
echo_to_log "Installing Guacamole extensions and MariaDB Java Client: Done!"

echo_to_log "Creating guacd conf file:..."
cat <<EOF >$GUACAMOLE_HOME/guacd.conf
[daemon]
pid_file = /var/run/guacd.pid
log_level = debug

[server]
bind_host = localhost
bind_port = 4822
EOF
echo === === === === guacd.conf === === === ===
cat $GUACAMOLE_HOME/guacd.conf
echo === === === === guacd.conf === === === ===
echo_to_log "Creating guacd conf file: Done!"

echo_to_log "Setting Tomcat as the owner of Guacamole configurations and configuring SElinux permissions:..."
chmod -R 755 $GUACAMOLE_HOME
chown -R tomcat:tomcat $GUACAMOLE_HOME
chcon -R system_u:object_r:usr_t:s0 $GUACAMOLE_HOME
chmod -R 755 /opt/tomcat/webapps
chown -R tomcat:tomcat /opt/tomcat/webapps
chcon -R system_u:object_r:usr_t:s0 /opt/tomcat/webapps
setsebool -P httpd_can_network_connect 1
setsebool -P tomcat_can_network_connect_db 1
echo_to_log "Setting Tomcat as the owner of Guacamole configurations and configuring SElinux permissions: Done!"

echo_to_log "Starting tomcat and guacd:..."
systemctl start tomcat
systemctl enable tomcat
systemctl start guacd
systemctl enable guacd
sleep 10
systemctl restart tomcat
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
echo_to_log "Configuring Firewall: Done!"

# === Run a Full System Update ===
echo_to_log "Running System update:..."
dnf update -y
echo_to_log "Running System update: Done!"

echo_to_log "User Data Script Complete!"
