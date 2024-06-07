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
    route53_zone = {
      public = {
        arn     = module.be.route53_zone_public.arn
        id      = module.be.route53_zone_public.id
        name    = module.be.route53_zone_public.name
        zone_id = module.be.route53_zone_public.zone_id
      }
    }
  }
}

output "frontend" {
  value = {
    s3 = {
      deployed_objects = module.fe.s3.deployed_objects
    }
  }
}
