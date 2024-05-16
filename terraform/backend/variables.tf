variable "module_name" {}
variable "module_slug" {}
variable "common" {}
locals {
  common_tags = {
    "Module Slug" = var.module_slug
  }
  restapi_id                  = "RESTAPIID"    # should come from api gateway portal2 api
  authorizer_id               = "AUTHORIZERID" # should come from api gateway portal2 api authorizer
  tablename_user_stacks       = "${var.common.environment}-UserStacksTable"
  tablename_available_dataset = "${var.common.environment}-AvailableDataset"
  tablename_trusted_users     = "${var.common.environment}-TrustedUsersTable"
  tablename_autoexport_users  = "${var.common.environment}-AutoExportUsersTable"
  tablename_export_file_request = "${var.common.environment}-RequestExportTable"
  tablename_manage_disk       = "${var.common.environment}-ManageDiskspaceRequestsTable"
  tablename_manage_disk_index = "${var.common.environment}-diskspace-username-index"
  tablename_manage_uptime     = "${var.common.environment}-ScheduleUptimeTable"
  tablename_manage_uptime_index = "${var.common.environment}-scheduleuptime-username-index"
  tablename_manage_user       = "${var.common.environment}-ManageUserWorkstationTable"
  tablename_manage_user_index = "${var.common.environment}-workstation-username-index"
  receiver_email              = "sdc-support@dot.gov"
  ecs_tags = { # ECS auto creates these tags. Putting them in Terraform will prevent config drift.
    "App Support" = "Jeff.Ussing.CTR"
    "Fed Owner"   = "Dan Morgan"
  }

}
