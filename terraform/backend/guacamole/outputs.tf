# use caution when making changes to outputs
# outputs are in the tfstate and may be used by other configurations
output "lb" {
  value = {
    dns_name = aws_lb.guacamole.dns_name
    zone_id  = aws_lb.guacamole.zone_id
  }
}
