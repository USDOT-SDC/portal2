# use caution when making changes to local.common
# local.common is output to tfstate and can be used by other configurations
output "debug" {
  value = {
    environment = local.common.environment
    repository  = local.default_tags.Repository
  }
}

output "backend" {
  value = {
    resource_urls = module.be.resource_urls
    s3 = {
      portal_bucket = module.be.s3.portal_bucket
    }
    route53_zone = {
      public = module.be.route53_zone_public
    }
  }
}

output "frontend" {
  value = {
    s3 = {
      portal_bucket    = module.be.s3.portal_bucket
      objects_deployed = module.fe.s3.objects_deployed
    }
  }
}
