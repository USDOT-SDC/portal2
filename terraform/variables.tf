locals {
  // Setup some local vars to hold static and dynamic data
  # use caution when making changes to local.common
  # local.common is output to tfstate and used by other configurations
  common = {
    account_id                  = nonsensitive(data.aws_ssm_parameter.account_id.value)
    region                      = nonsensitive(data.aws_ssm_parameter.region.value)
    environment                 = nonsensitive(data.aws_ssm_parameter.environment.value)
    support_email               = nonsensitive(data.aws_ssm_parameter.support_email.value)
    admin_email                 = nonsensitive(data.aws_ssm_parameter.admin_email.value)
    vpc                         = data.terraform_remote_state.infrastructure.outputs.vpc
    terraform_bucket            = data.terraform_remote_state.infrastructure.outputs.s3.terraform
    backup_bucket               = data.terraform_remote_state.infrastructure.outputs.s3.backup
    instance_maintenance_bucket = data.terraform_remote_state.infrastructure.outputs.s3.instance_maintenance
    certificates                = data.terraform_remote_state.infrastructure.outputs.certificates
    app_slug                    = "portal2"
    secrets_path                = "../../portal2-secrets"
  }
  default_tags = {
    "Repository URL" = "https://github.com/USDOT-SDC/"
    Repository       = "portal2"
    Project          = "Platform"
    Team             = "Platform"
    Owner            = "Support Team"
  }
}

# === Variables to build the FQDN ===
locals {
  dev_fqdn  = "sdc-dev.dot.gov"
  prod_fqdn = "sdc.dot.gov"
  fqdn      = local.common.environment == "dev" ? local.dev_fqdn : local.prod_fqdn
}
