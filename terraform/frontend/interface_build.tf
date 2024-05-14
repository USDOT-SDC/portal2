locals {
  working_dir               = "${path.module}/interface"
  src_path                  = "${path.module}/interface/src"
  build_path                = "${path.module}/interface_build"
  environment_ts_tpl_path   = "${path.module}/environment.ts.tpl"
  environment_ts_path       = "${path.module}/interface/src/environments/environment.${var.common.environment}.ts"
  environment_ts_local_path = "${path.module}/interface/src/environments/environment.ts"
  configuration             = var.common.environment == "dev" ? "development" : "production"
  tpl_vars = {
    production = var.common.environment == "dev" ? "false" : "true"
    stage      = var.common.environment
    build      = "2.0.1"
  }
}

data "template_file" "environment_ts" {
  template = file(local.environment_ts_tpl_path)
  vars = {
    production     = local.tpl_vars.production
    stage          = local.tpl_vars.stage
    build          = local.tpl_vars.build
    portal_url     = var.backend.resource_urls.portal
    portal_api_url = var.backend.resource_urls.portal_api
    guacamole_url  = var.backend.resource_urls.guacamole
    sftp_url       = var.backend.resource_urls.sftp
    sub1_url       = var.backend.resource_urls.sub1
    sub2_url       = var.backend.resource_urls.sub2
  }
}

resource "local_file" "environment_ts" {
  content    = data.template_file.environment_ts.rendered
  filename   = local.environment_ts_path
  depends_on = [data.template_file.environment_ts]
}

resource "local_file" "environment_ts_local" {
  count      = var.common.environment == "dev" ? 1 : 0
  content    = data.template_file.environment_ts.rendered
  filename   = local.environment_ts_local_path
  depends_on = [data.template_file.environment_ts]
}

resource "terraform_data" "npm_install" {
  provisioner "local-exec" {
    working_dir = local.working_dir
    command     = "npm install"
  }
  depends_on = [local_file.environment_ts]
}

resource "terraform_data" "ng_build" {
  provisioner "local-exec" {
    working_dir = local.working_dir
    command     = "ng build --configuration ${local.configuration}"
  }
  depends_on = [terraform_data.npm_install]
}

module "interface_build" {
  source = "hashicorp/dir/template"
  # base_dir = local.src_path # using src_path for testing
  base_dir   = local.build_path
  depends_on = [terraform_data.ng_build]
}

resource "aws_s3_object" "interface_build" {
  for_each               = module.interface_build.files
  bucket                 = var.backend.s3.portal_bucket
  key                    = each.key
  content_type           = each.value.content_type
  source                 = each.value.source_path
  source_hash            = filemd5(each.value.source_path)
  server_side_encryption = "AES256"
  depends_on             = [module.interface_build]
}
