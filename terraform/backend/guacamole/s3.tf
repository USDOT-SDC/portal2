data "template_file" "user_data" {
  template = file("${path.module}/ec2-user-data.sh")
  vars = {
    mariadb_password         = nonsensitive(data.aws_ssm_parameter.mariadb_password.value),
    mariadb_endpoint         = data.aws_db_instance.mariadb.endpoint,
    aws_region               = var.common.region,
    cognito_pool_id          = var.cognito.user_pool.id
    environment              = var.common.environment
    terraform_bucket         = var.common.terraform_bucket.bucket
    tomcat_version           = "10.1.35"
    tomcat_key               = aws_s3_object.files["apache-tomcat-10.1.35.tar.gz"].key
    guac_version             = "1.5.5"
    guac_war_key             = aws_s3_object.files["guacamole-1.5.5.war"].key
    guac_auth_jdbc_key       = aws_s3_object.files["guacamole-auth-jdbc-1.5.5.tar.gz"].key
    guac_auth_sso_key        = aws_s3_object.files["guacamole-auth-sso-1.5.5.tar.gz"].key
    mariadb_client_version   = "3.5.1"
    mariadb_client_key       = aws_s3_object.files["mariadb-java-client-3.5.1.jar"].key
    disk_alert_script_bucket = var.common.disk_alert_linux_script.bucket
    disk_alert_script_key    = var.common.disk_alert_linux_script.key
  }
}

# resource "aws_s3_object" "user_data" {
#   bucket                 = var.common.terraform_bucket.bucket
#   key                    = "portal2/terraform/be/guacamole/user-data.sh"
#   content                = data.template_file.user_data.rendered
#   content_type           = "text/x-shellscript"
#   server_side_encryption = "AES256"
#   depends_on             = [data.template_file.user_data]
# }

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
