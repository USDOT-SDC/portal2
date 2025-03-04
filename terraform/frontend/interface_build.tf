locals {
  working_dir               = "${path.module}/interface"
  src_path                  = "${path.module}/interface/src"
  build_path                = "${path.module}/interface_build"
  environment_ts_tpl_path   = "${path.module}/environment.ts.tpl"
  environment_ts_path       = "${path.module}/environment.${var.common.environment}.ts"
  tpl_vars = {
    production = var.common.environment == "dev" ? "false" : "true"
    stage      = var.common.environment
    build      = var.common.config_version
  }
}

data "template_file" "environment_ts" {
  template = file(local.environment_ts_tpl_path)
  vars = {
    production = local.tpl_vars.production
    stage      = local.tpl_vars.stage
    build      = local.tpl_vars.build
    # build_datetime          = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
    portal_url              = var.backend.resource_urls.portal
    portal_api_url          = var.backend.resource_urls.portal_api
    guacamole_url           = var.backend.resource_urls.guacamole
    sftp_url                = var.backend.resource_urls.sftp
    sub1_url                = var.backend.resource_urls.sub1
    sub2_url                = var.backend.resource_urls.sub2
    user_pool_id            = var.backend.cognito.user_pool.id
    user_pool_domain        = var.backend.cognito.user_pool.domain
    user_pool_client_id     = var.backend.cognito.user_pool.client.id
    user_pool_client_scopes = join(" ", var.backend.cognito.user_pool.client.allowed_oauth_scopes)
  }
}

resource "local_file" "environment_ts" {
  content    = data.template_file.environment_ts.rendered
  filename   = local.environment_ts_path
  depends_on = [data.template_file.environment_ts]
}

module "interface_build" {
  source     = "hashicorp/dir/template"
  base_dir   = local.build_path
}

resource "aws_s3_object" "interface_build" {
  for_each               = module.interface_build.files
  bucket                 = var.backend.s3.portal.bucket
  key                    = each.key
  content_type           = each.value.content_type
  source                 = each.value.source_path
  source_hash            = filemd5(each.value.source_path)
  server_side_encryption = "AES256"
  depends_on             = [module.interface_build]
}
