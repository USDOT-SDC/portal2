# Backend
module "be" {
  module_name  = "Backend"
  module_slug  = "be"
  source       = "./backend"
  common       = local.common
  route53_zone = data.terraform_remote_state.infrastructure.outputs.route53_zone
  certificates = data.terraform_remote_state.infrastructure.outputs.certificates
  fqdn         = local.fqdn
}

# Frontend
module "fe" {
  module_name = "Frontend"
  module_slug = "fe"
  source      = "./frontend"
  common      = local.common
  fqdn        = local.fqdn
  backend = {
    resource_urls = module.be.resource_urls
    s3 = {
      portal = module.be.s3.portal
    }
  }
}
