# use caution when making changes to outputs
# outputs are in the tfstate and may be used by other configurations
output "foo" {
  value = aws_lambda_layer_version.foo
}