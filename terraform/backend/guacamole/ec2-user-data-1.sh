#! /bin/bash
exec > >(tee /tmp/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# Echo to a custom log file since STDOUT is not captured
ECHO_FILE=/tmp/user-data-echo.log
echo_to_log() {
    echo "$(date) - $1"
    echo "$(date) - $1" >>$ECHO_FILE
}

# === System Setup ===
echo_to_log "Getting info from meta-data:..."
# Get our instance ID
INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
echo_to_log "instance-id: $INSTANCE_ID "
# Get our IP address
IP_ADDRESS=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
IFS=. read ip1 ip2 ip3 ip4 <<<"$IP_ADDRESS"
echo_to_log "IP Address: $IP_ADDRESS "
echo_to_log "Getting info from meta-data: Done!"

echo_to_log "Setting hostname:..."
hostnamectl set-hostname guacamole-$ip3-$ip4.${environment}.sdc.dot.gov
/usr/local/bin/aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Name,Value=guacamole-$ip3-$ip4
echo_to_log "Setting hostname: Done!"

# === System Updates ===
echo_to_log "Updating packages..."
rpm --import http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-8
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf config-manager --set-enabled codeready-builder-for-rhel-8-rhui-rpms
/usr/bin/crb enable
dnf install epel-release -y
dnf update -y
echo_to_log "Updating packages: Done!"

echo_to_log "Setup dnf automatic..."
dnf install dnf-automatic -y
cat <<'EOF' >/etc/dnf/automatic.conf
[commands]
upgrade_type = security
download_updates = yes
apply_updates = yes
network_online = 60
EOF
systemctl enable --now dnf-automatic.timer
echo_to_log "Setup dnf automatic: Done!"

# === Install Tomcat and Prerequisites ===
echo_to_log "Installing JDK..."
dnf install -y temurin-21-jdk
groupadd tomcat
useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
cd /opt
echo_to_log "Installing JDK: Done!"

echo_to_log "Installing Tomcat..."
/usr/local/bin/aws s3 cp s3://${terraform_bucket}/${tomcat_key} apache-tomcat-${tomcat_version}.tar.gz
tar -xvzf apache-tomcat-${tomcat_version}.tar.gz
mv apache-tomcat-${tomcat_version} /opt/tomcat
chown -R tomcat:tomcat /opt/tomcat/apache-tomcat-${tomcat_version}
chmod o+x /opt/tomcat/apache-tomcat-${tomcat_version}/bin

cat <<EOF >/etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat 9 Server
After=network.target
[Service]
Type=forking
User=tomcat
Group=tomcat
Environment="JAVA_HOME=/usr/lib/jvm/java-21-openjdk"
Environment="JAVA_OPTS=-Xms512m -Xmx512m"
Environment="CATALINA_HOME=/opt/tomcat/apache-tomcat-${tomcat_version}"
Environment="CATALINA_BASE=/opt/tomcat/apache-tomcat-${tomcat_version}"
Environment="CATALINA_PID=/opt/tomcat/apache-tomcat-${tomcat_version}/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
ExecStart=/opt/tomcat/apache-tomcat-${tomcat_version}/bin/startup.sh
ExecStop=/opt/tomcat/apache-tomcat-${tomcat_version}/bin/shutdown.sh
UMask=0007
RestartSec=10
Restart=always
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start tomcat
echo_to_log "Installing Tomcat: Done!"

# === Install Guacamole ===
echo_to_log "Installing Guacamole and its prerequisites"
curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash
dnf install MariaDB-client MariaDB-shared -y
dnf install xfreerdp guacd -y
dnf install libguac-client-vnc libguac-client-rdp -y

echo_to_log "Creating Guacamole configuration folders..."
mkdir -p /etc/guacamole/extensions
mkdir -p /etc/guacamole/lib
echo_to_log "Creating Guacamole configuration folders: Done!"

echo_to_log "Stopping tomcat:..."
service tomcat stop
echo_to_log "Stopping tomcat: Done!"

echo_to_log "Creating guacamole property file..."

echo_to_log "Copying down Guacamole binaries"
/usr/local/bin/aws s3 cp s3://${terraform_bucket}/${guac_war_key} /opt/tomcat/apache-tomcat-${tomcat_version}/webapps/guacamole.war
/usr/local/bin/aws s3 cp s3://${terraform_bucket}/${guac_auth_jdbc_key} /etc/guacamole/extensions/guacamole-auth-jdbc-${guac_version}.tar.gz
/usr/local/bin/aws s3 cp s3://${terraform_bucket}/${guac_auth_sso_key} /etc/guacamole/extensions/guacamole-auth-sso-${guac_version}.tar.gz
/usr/local/bin/aws s3 cp s3://${terraform_bucket}/${mariadb_client_key} /etc/guacamole/lib/mariadb-java-client-${mariadb_client_version}.jar
echo_to_log "Copying down Guacamole binaries: Done!"

unzip /opt/tomcat/apache-tomcat-${tomcat_version}/webapps/guacamole.war -d /opt/tomcat/apache-tomcat-${tomcat_version}/webapps/guacamole/
yes | rm /opt/tomcat/apache-tomcat-${tomcat_version}/webapps/guacamole.war
chown -R tomcat:tomcat /opt/tomcat
chcon -R system_u:object_r:usr_t:s0 /opt/tomcat

echo_to_log "Creating guacamole property file.."
cat <<EOF >/etc/guacamole/guacamole.properties
mysql-driver: mariadb
mysql-hostname: ${mariadb_database_endpoint}
mysql-port: 3306
mysql-database: guacamole_db
mysql-username: guacamole_user
mysql-password: ${mariadb_password}
http-auth-header: REMOTE_USER
cognito-web-key-url: https://cognito-idp.us-east-1.amazonaws.com/${cognito_pool_id}/.well-known/jwks.json
http-request-param: authToken
guacd-hostname: 127.0.0.1
mysql-ssl-mode : disabled
guacd-ssl: false
EOF
echo_to_log "Creating guacamole property file: Done!"

echo_to_log "Creating guacd conf file..."
cat <<EOF >/etc/guacamole/guacd.conf
[daemon]
#pid_file = /var/run/guacd.pid
log_level = debug
[server]
bind_host = 127.0.0.1
bind_port = 4822
EOF
echo_to_log "Creating guacd conf file: Done!"

echo_to_log "Setting Tomcat as the owner of Guacamole configurations and configuring SElinux permissions"
chmod -R 755 /etc/guacamole
chown -R tomcat:tomcat /etc/guacamole
chcon -R system_u:object_r:usr_t:s0 /etc/guacamole
chmod -R 755 /opt/tomcat/apache-tomcat-${tomcat_version}/webapps
chown -R tomcat:tomcat /opt/tomcat/apache-tomcat-${tomcat_version}/webapps
chcon -R system_u:object_r:usr_t:s0 /opt/tomcat/apache-tomcat-${tomcat_version}/webapps
setsebool -P httpd_can_network_connect 1
setsebool -P tomcat_can_network_connect_db 1

echo_to_log "Starting tomcat and guacd:..."
systemctl start tomcat
systemctl enable tomcat
systemctl start guacd
systemctl enable guacd
sleep 10
service tomcat restart
echo_to_log "Starting tomcat and guacd: Done!"

systemctl stop firewalld

firewall-offline-cmd --zone=public --add-port=8080/tcp
firewall-offline-cmd --zone=public --add-port=443/tcp

firewall-offline-cmd --zone=public --add-port=4822/tcp
firewall-offline-cmd --zone=public --add-port=52311/tcp
firewall-offline-cmd --zone=public --add-port=52311/udp
sleep 2 # Add a 2-second delay
systemctl start firewalld
firewall-cmd --reload
echo_to_log "Add allow port 52311 for BigFix: Done!"


echo_to_log "setup the disk monitor alert"
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
echo_to_log "Setup the disk monitor alert: Done!"

echo_to_log "Initialization complete!"
