locals {
  tomcat_version          = "9.0.118"
  guac_version            = "1.6.0"
  mysql_connector_version = "9.6.0"
  guacd_log_level         = var.common.environment == "prod" ? "info" : "debug"
}

data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh")
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
    tomcat_version           = local.tomcat_version
    tomcat_key               = aws_s3_object.files["apache-tomcat-${local.tomcat_version}.tar.gz"].key
    guac_version             = local.guac_version
    guac_war_key             = aws_s3_object.files["guacamole-${local.guac_version}.war"].key
    guac_auth_jdbc_mysql_key = aws_s3_object.files["guacamole-auth-jdbc-mysql-${local.guac_version}.jar"].key
    guac_auth_header_version = local.guac_version
    guac_auth_header_key     = aws_s3_object.files["guacamole-auth-header-${local.guac_version}.jar"].key
    mysql_connector_version  = local.mysql_connector_version
    mysql_connector_key      = aws_s3_object.files["mysql-connector-j-${local.mysql_connector_version}.jar"].key
    disk_alert_script_bucket = var.common.disk_alert_linux_script.bucket
    disk_alert_script_key    = var.common.disk_alert_linux_script.key
    config_version           = var.common.config_version
    guacd_rpms_prefix        = "portal2/terraform/be/guacamole/files/guacd-rpms/"
    guacd_log_level          = local.guacd_log_level
  }
}

resource "aws_s3_object" "user_data" {
  bucket                 = var.common.terraform_bucket.bucket
  key                    = "portal2/terraform/be/guacamole/files/user-data.sh"
  content                = data.template_file.user_data.rendered
  content_type           = "text/x-shellscript"
  server_side_encryption = "AES256"
  depends_on             = [data.template_file.user_data]
}
