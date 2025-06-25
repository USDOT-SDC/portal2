# use caution when making changes to outputs
# outputs are in the tfstate and may be used by other configurations
output "lb" {
  value = {
    dns_name = var.common.environment == "prod" ? aws_lb.guacamole_nlb["deployed"].dns_name : aws_lb.guacamole_alb["deployed"].dns_name
    zone_id  = var.common.environment == "prod" ? aws_lb.guacamole_nlb["deployed"].zone_id : aws_lb.guacamole_alb["deployed"].zone_id
  }
}
