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
