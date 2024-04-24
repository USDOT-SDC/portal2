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
  source = "./frontend"
  common = local.common
}
