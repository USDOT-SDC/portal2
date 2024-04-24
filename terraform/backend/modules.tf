# Hello World Lambda
module "hwl" {
  source      = "./lambdas/hello_world"
  module_name = "${var.module_name}, Hello World Lambda"
  module_slug = "${var.module_slug}.hwl"
  common      = var.common
}
