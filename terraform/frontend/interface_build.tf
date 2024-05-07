locals {
  src_path          = "${path.module}\\interface\\src"
  build_path        = "${path.module}\\interface_build"
  build_config_path = "${path.module}\\interface\\config_${var.common.environment}"  
}

# This, or something like it, will be used once the frontend code is ready
# resource "terraform_data" "ng_build" {
#   provisioner "local-exec" {
#     command = "ng build --configuration=${local.build_config_path}"
#   }
# }

module "interface_build" {
  source   = "hashicorp/dir/template"
  base_dir = local.src_path # using src_path for testing
  # base_dir   = local.build_path
  # depends_on = [terraform_data.ng_build]
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
