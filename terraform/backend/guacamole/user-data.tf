locals {
  tomcat_version          = "9.0.115"
  guac_version            = "1.6.0"
  mysql_connector_version = "9.6.0"

  # Bump epel_fetch_version to force Terraform to re-fetch EPEL files from Fedora on next apply.
  epel_fetch_version    = "2026-03-11"
  epel_rpm_filename     = "epel-release-latest-9.noarch.rpm"
  epel_gpg_filename     = "RPM-GPG-KEY-EPEL-9"
}

# Fetch EPEL RPM and GPG key from Fedora and upload directly to S3.
# Re-runs only when epel_fetch_version is bumped.
# Requires AWS credentials in the environment (AWS_PROFILE or equivalent).
resource "terraform_data" "epel_files" {
  triggers_replace = [local.epel_fetch_version]

  provisioner "local-exec" {
    command = join(" && ", [
      "curl -fsSL https://dl.fedoraproject.org/pub/epel/${local.epel_rpm_filename} -o ${path.module}/files/${local.epel_rpm_filename}",
      "curl -fsSL http://download.fedoraproject.org/pub/epel/${local.epel_gpg_filename} -o ${path.module}/files/${local.epel_gpg_filename}",
    ])
  }
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
    epel_rpm_key             = aws_s3_object.files[local.epel_rpm_filename].key
    epel_gpg_key             = aws_s3_object.files[local.epel_gpg_filename].key
  }
  depends_on = [ terraform_data.epel_files ]
}

resource "aws_s3_object" "user_data" {
  bucket                 = var.common.terraform_bucket.bucket
  key                    = "portal2/terraform/be/guacamole/files/user-data.sh"
  content                = data.template_file.user_data.rendered
  content_type           = "text/x-shellscript"
  server_side_encryption = "AES256"
  depends_on             = [data.template_file.user_data]
}
