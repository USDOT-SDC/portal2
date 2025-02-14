#! /bin/bash
exec > >(tee /tmp/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# Echo to a custom log file since STDOUT is not captured
ECHO_FILE=/tmp/user-data-echo.log
echo_to_log() {
    echo "================================================================================"
    echo "    $1"
    echo "================================================================================"
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
chown -R tomcat:tomcat $TOMCAT_HOME
chcon -R system_u:object_r:usr_t:s0 $TOMCAT_HOME
echo_to_log "Deploying Guacamole Client: Done!"

echo_to_log "Creating Guacamole Client property file:..."
mkdir -p $GUACAMOLE_HOME
cat <<EOF >$GUACAMOLE_HOME/guacamole.properties
guacd-hostname: localhost
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

echo_to_log "Creating Guacamole Client context file:..."
# Converts Servlet 4.0 to Servlet 5.0 applications
cat <<EOF >$TOMCAT_HOME/conf/Catalina/localhost/guacamole.xml
<Context>
   <Loader jakartaConverter="TOMCAT" />
</Context>
EOF
echo === === === === guacamole.xml === === === ===
cat $TOMCAT_HOME/conf/Catalina/localhost/guacamole.xml
echo === === === === guacamole.xml === === === ===
echo_to_log "Creating Guacamole Client context file: Done!"



# echo_to_log "Installing MariaDB Client:..."
# run the following for help
# curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | bash -s -- --help
# curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | bash -s -- --os-type=rhel --os-version=8
# dnf install MariaDB-shared -y
# dnf install MariaDB-client -y
# echo_to_log "Installing MariaDB Client: Done!"

echo_to_log "Guacamole Server and prerequisites:..."
dnf install guacd-${guac_version} -y
dnf install libguac-client-rdp -y
# dnf install libguac-client-vnc -y
dnf install xfreerdp -y
echo_to_log "Guacamole Server and prerequisites: Done!"

echo_to_log "Installing Guacamole extensions and MariaDB Java Client:..."
mkdir -p $GUACAMOLE_HOME/extensions
mkdir -p $GUACAMOLE_HOME/lib

GUACAMOLE_AUTH_JDBC_PATH=$GUACAMOLE_HOME/extensions/guacamole-auth-jdbc-${guac_version}
aws s3 cp s3://${terraform_bucket}/${guac_auth_jdbc_key} $GUACAMOLE_AUTH_JDBC_PATH.tar.gz
tar -xvzf $GUACAMOLE_AUTH_JDBC_PATH.tar.gz --directory $GUACAMOLE_HOME/extensions >/dev/null
cp $GUACAMOLE_AUTH_JDBC_PATH/mysql/guacamole-auth-jdbc-mysql-${guac_version}.jar $GUACAMOLE_HOME/extensions/
yes | rm -rf $GUACAMOLE_AUTH_JDBC_PATH
yes | rm $GUACAMOLE_AUTH_JDBC_PATH.tar.gz

GUACAMOLE_AUTH_SSO_PATH=$GUACAMOLE_HOME/extensions/guacamole-auth-sso-${guac_version}
aws s3 cp s3://${terraform_bucket}/${guac_auth_sso_key} $GUACAMOLE_AUTH_SSO_PATH.tar.gz
tar -xvzf $GUACAMOLE_AUTH_SSO_PATH.tar.gz --directory $GUACAMOLE_HOME/extensions >/dev/null
cp $GUACAMOLE_AUTH_SSO_PATH/openid/guacamole-auth-sso-openid-${guac_version}.jar $GUACAMOLE_HOME/extensions/
yes | rm -rf $GUACAMOLE_AUTH_SSO_PATH
yes | rm $GUACAMOLE_AUTH_SSO_PATH.tar.gz

MARIADB_JAVA_CLIENT_PATH=$GUACAMOLE_HOME/lib/mariadb-java-client-${mariadb_client_version}
aws s3 cp s3://${terraform_bucket}/${mariadb_client_key} $MARIADB_JAVA_CLIENT_PATH.jar
echo_to_log "Installing Guacamole extensions and MariaDB Java Client: Done!"

echo_to_log "Creating guacd conf file:..."
cat <<EOF >$GUACAMOLE_HOME/guacd.conf
[daemon]
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
chmod -R 755 $TOMCAT_HOME/webapps
chown -R tomcat:tomcat $TOMCAT_HOME/webapps
chcon -R system_u:object_r:usr_t:s0 $TOMCAT_HOME/webapps
setsebool -P httpd_can_network_connect 1
setsebool -P tomcat_can_network_connect_db 1
echo_to_log "Setting Tomcat as the owner of Guacamole configurations and configuring SElinux permissions: Done!"

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
echo_to_log "Configuring Firewall: Done!"

# === Run a Full System Update ===
echo_to_log "Running System update:..."
dnf update -y
echo_to_log "Running System update: Done!"

echo_to_log "User Data Script Complete!"
