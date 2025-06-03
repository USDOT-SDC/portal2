variable "module_name" {}
variable "module_slug" {}
variable "common" {}
variable "route53_zone" {}
variable "certificates" {}
variable "fqdn" {}
locals {
  common_tags = {
    "Module Slug" = var.module_slug
  }
  tablename_autoexport_users  = "${var.common.environment}-AutoExportUsersTable"
  tablename_available_dataset = "${var.common.environment}-AvailableDataset"
  tablename_manage_disk       = "${var.common.environment}-ManageDiskspaceRequestsTable"
  tablename_manage_disk_index = "${var.common.environment}-diskspace-username-index"
  # tablename_user_stacks         = "${var.common.environment}-UserStacksTable"
  user_stacks_table         = aws_dynamodb_table.user_stacks
  tablename_prefix              = var.common.environment == "dev" ? "dev" : "production"
  tablename_manage_user         = "${local.tablename_prefix}-ManageUserWorkstationTable"
  tablename_manage_user_index   = "${local.tablename_prefix}-workstation-username-index"
  tablename_export_file_request = "${local.tablename_prefix}-RequestExportTable"
  tablename_manage_uptime       = "${local.tablename_prefix}-ScheduleUptimeTable"
  tablename_manage_uptime_index = "${local.tablename_prefix}-scheduleuptime-username-index"
  tablename_trusted_users       = "${local.tablename_prefix}-TrustedUsersTable"
  receiver_email                = "sdc-support@dot.gov"
  ecs_tags = { # ECS auto creates these tags. Putting them in Terraform will prevent config drift.
    "App Support" = "Jeff.Ussing.CTR"
    "Fed Owner"   = "Dan Morgan"
  }
  dev_web_acl_id  = "arn:aws:wafv2:us-east-1:505135622787:global/webacl/FMManagedWebACLV2-Enable-Shield-Advanced-Global-Policy-1681826198080/81323598-c0ec-4d6e-8690-95c47433d82e"
  prod_web_acl_id = "arn:aws:wafv2:us-east-1:004118380849:global/webacl/FMManagedWebACLV2-Enable-Shield-Advanced-Global-Policy-1681826031617/91b49653-e00e-4d6a-86a3-9041f4de20ce"
  web_acl_id      = var.common.environment == "dev" ? local.dev_web_acl_id : local.prod_web_acl_id
}
