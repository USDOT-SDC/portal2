# resource "terraform_data" "ng_build" {
#   provisioner "local-exec" {
#     command = "ng build --configuration=${var.common.environment}"
#   }
# }

module "interface_build" {
  source     = "hashicorp/dir/template"
  base_dir   = "${path.module}/interface_build"
  # depends_on = [terraform_data.ng_build]
}

resource "aws_s3_object" "interface_build" {
  for_each               = module.interface_build.files
  bucket                 = var.backend.s3.portal_bucket
  key                    = each.key
  content_type           = each.value.content_type
  source                 = each.value.source_path
  server_side_encryption = "AES256"
  depends_on             = [module.interface_build]
}
