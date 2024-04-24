locals {
  // Setup some local vars to hold static and dynamic data
  # use caution when making changes to local.common
  # local.common is output to tfstate and used by other configurations
  common = {
    account_id  = nonsensitive(data.aws_ssm_parameter.account_id.value)
    region      = nonsensitive(data.aws_ssm_parameter.region.value)
    environment = nonsensitive(data.aws_ssm_parameter.environment.value)
    network = {
      vpc = data.terraform_remote_state.infrastructure.outputs.common.network.vpc
      subnet_ids = [
        data.terraform_remote_state.infrastructure.outputs.common.network.subnet_support.id,
        data.terraform_remote_state.infrastructure.outputs.common.network.subnet_researcher.id,
        data.terraform_remote_state.infrastructure.outputs.common.network.subnet_three.id,
        data.terraform_remote_state.infrastructure.outputs.common.network.subnet_four.id,
        data.terraform_remote_state.infrastructure.outputs.common.network.subnet_five.id,
        data.terraform_remote_state.infrastructure.outputs.common.network.subnet_six.id
      ]
      subnet_support         = data.terraform_remote_state.infrastructure.outputs.common.network.subnet_support
      subnet_researcher      = data.terraform_remote_state.infrastructure.outputs.common.network.subnet_researcher
      subnet_three           = data.terraform_remote_state.infrastructure.outputs.common.network.subnet_three
      subnet_four            = data.terraform_remote_state.infrastructure.outputs.common.network.subnet_four
      subnet_five            = data.terraform_remote_state.infrastructure.outputs.common.network.subnet_five
      subnet_six             = data.terraform_remote_state.infrastructure.outputs.common.network.subnet_six
      default_security_group = data.terraform_remote_state.infrastructure.outputs.common.network.default_security_group
      transit_gateway        = data.terraform_remote_state.infrastructure.outputs.common.network.transit_gateway
    }
    support_email               = nonsensitive(data.aws_ssm_parameter.support_email.value)
    admin_email                 = nonsensitive(data.aws_ssm_parameter.admin_email.value)
    terraform_bucket            = data.terraform_remote_state.infrastructure.outputs.common.terraform_bucket
    backup_bucket               = data.terraform_remote_state.infrastructure.outputs.common.backup_bucket
    instance_maintenance_bucket = data.terraform_remote_state.infrastructure.outputs.common.instance_maintenance_bucket
    app_slug                    = "portal2"
  }
  default_tags = {
    "Repository URL" = "https://github.com/USDOT-SDC/"
    Repository       = "portal2"
    Project          = "Platform"
    Team             = "Platform"
    Owner            = "Support Team"
  }
}
