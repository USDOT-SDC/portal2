# use caution when making changes to outputs
# they are put into the tfstate file and can be used by other Terraform configurations
# output "debug" {
#   value = {
#     infrastructure_outputs = data.terraform_remote_state.infrastructure.outputs
#   }
# }

output "backend" {
  value = {
    resource_urls = module.be.resource_urls
    s3 = {
      portal = module.be.s3.portal
    }
    api_gateway_deployment_hash_map = module.be.api_gateway_deployment_hash_map
    cognito                         = module.be.cognito
  }
}

output "frontend" {
  value = {
    s3 = {
      deployed_objects = module.fe.s3.deployed_objects
    }
  }
}
