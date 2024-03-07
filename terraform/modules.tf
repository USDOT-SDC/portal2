# module "utilities" {
#   source = "./utilities"
#   common = local.common
# }

# module "lambda_hello_world" {
#   source      = "terraform-aws-modules/lambda/aws"
#   source_path = "src/lambdas/hello_world"

#   function_name = "hello_world"
#   description   = "Portal 2 awesome lambda function"
#   handler       = "lambda_function.lambda_handler"
#   runtime       = "python3.11"

#   tags = {
#     Name = "Portal 2 Hello World"
#   }
# }
