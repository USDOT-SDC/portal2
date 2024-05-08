locals {
  working_dir   = "${path.module}\\interface"
  src_path      = "${path.module}\\interface\\src"
  build_path    = "${path.module}\\interface_build"
  configuration = var.common.environment == "dev" ? "development" : "production"
}

resource "terraform_data" "npm_install" {
  provisioner "local-exec" {
    working_dir = local.working_dir
    command     = "npm install"
  }
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
