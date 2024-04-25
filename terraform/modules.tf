# Backend
module "be" {
  module_name = "Backend"
  module_slug = "be"
  source      = "./backend"
  common      = local.common
}

# Frontend
module "fe" {
  module_name = "Frontend"
  module_slug = "fe"
  source      = "./frontend"
  common      = local.common
  backend = {
    rest_api = {
      id  = module.be.rest_api.id
      url = module.be.rest_api.url
    }
    s3 = {
      portal_bucket = module.be.s3.portal_bucket
    }
  }
}
