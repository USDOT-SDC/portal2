data "template_file" "user_data" {
  template = file("${path.module}/ec2-user-data.sh")
  vars = {
    mariadb_password         = nonsensitive(data.aws_ssm_parameter.mariadb_password.value),
    mariadb_address          = data.aws_db_instance.mariadb.address,
    aws_region               = var.common.region,
    cognito_pool_id          = var.cognito.user_pool.id
    cognito_pool_domain      = var.cognito.user_pool.domain
    cognito_pool_endpoint    = var.cognito.user_pool.endpoint
    cognito_pool_client_id   = var.cognito.user_pool.client.id
    fqdn                     = var.fqdn
    environment              = var.common.environment
    terraform_bucket         = var.common.terraform_bucket.bucket
    tomcat_version           = "9.0.100"
    tomcat_key               = aws_s3_object.files["apache-tomcat-9.0.100.tar.gz"].key
    guac_version             = "1.5.5"
    guac_war_key             = aws_s3_object.files["guacamole-1.5.5.war"].key
    guac_auth_jdbc_mysql_key = aws_s3_object.files["guacamole-auth-jdbc-mysql-1.5.5.jar"].key
    guac_auth_header_key     = aws_s3_object.files["guacamole-auth-header-0.9.14.jar"].key
    guac_web_xml_key         = aws_s3_object.web_xml.key
    mysql_connector_version  = "9.2.0"
    mysql_connector_key      = aws_s3_object.files["mysql-connector-j-9.2.0.jar"].key
    disk_alert_script_bucket = var.common.disk_alert_linux_script.bucket
    disk_alert_script_key    = var.common.disk_alert_linux_script.key
    config_version           = var.common.config_version
    git_commit               = var.common.git_commit_head_sha1
  }
}

resource "aws_s3_object" "user_data" {
  bucket                 = var.common.terraform_bucket.bucket
  key                    = "portal2/terraform/be/guacamole/files/ec2-user-data.sh"
  content                = data.template_file.user_data.rendered
  content_type           = "text/x-shellscript"
  server_side_encryption = "AES256"
  depends_on             = [data.template_file.user_data]
}

data "template_file" "web_xml" {
  template = file("${path.module}/web.xml")
  vars = {
    portal_url = var.portal_url
  }
}

resource "aws_s3_object" "web_xml" {
  bucket                 = var.common.terraform_bucket.bucket
  key                    = "portal2/terraform/be/guacamole/files/web.xml"
  content                = data.template_file.web_xml.rendered
  content_type           = "text/xml"
  server_side_encryption = "AES256"
  depends_on             = [data.template_file.web_xml]
}

# === Contents of Files ===
# == Tomcat == 
#    (https://tomcat.apache.org/download-90.cgi -> {version} -> Binary Distributions -> Core)
# apache-tomcat-{version}.tar.gz
# == Guacamole == 
#    (https://guacamole.apache.org/releases/ -> {version})
# guacamole-{version}.war
# guacamole-auth-header-{version}.jar
# guacamole-auth-jdbc-mysql-{version}.jar
# web.xml from: https://github.com/apache/guacamole-client/blob/main/guacamole/src/main/webapp/WEB-INF/web.xml
# == MySQL Connector/J == 
#    (https://dev.mysql.com/downloads/connector/j/ Select[Platform Independent] .jar is inside the archive)
# mysql-connector-j-{version}.jar
module "files" {
  source   = "hashicorp/dir/template"
  base_dir = "${path.module}/files"
}

resource "aws_s3_object" "files" {
  for_each               = module.files.files
  bucket                 = var.common.terraform_bucket.bucket
  key                    = "portal2/terraform/be/guacamole/files/${each.key}"
  content_type           = each.value.content_type
  source                 = each.value.source_path
  source_hash            = filemd5(each.value.source_path)
  server_side_encryption = "AES256"
  depends_on             = [module.files]
}
