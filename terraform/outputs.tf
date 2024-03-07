# use caution when making changes to local.common
# local.common is output to tfstate and can be used by other configurations
output "Repository" {
  value = local.default_tags.Repository
}
