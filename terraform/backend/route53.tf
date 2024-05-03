# === Variables to build the FQDN ===
variable "dev_fqdn" {
  default = "sdc-dev.dot.gov"
}

variable "prod_fqdn" {
  default = "sdc.dot.gov"
}

locals {
  fqdn = var.common.environment == "dev" ? var.dev_fqdn : var.prod_fqdn
}

# === Public DNS Zone ===
resource "aws_route53_zone" "public" {
  name    = local.fqdn
  comment = "Hosted zone for DOT DNS to route any requests to *.${local.fqdn}; this is used for the portal and other resources."
  tags    = local.ecs_tags
}

# === Name Server Record ===
resource "aws_route53_record" "ns" {
  name            = local.fqdn
  allow_overwrite = true
  ttl             = 172800
  type            = "NS"
  zone_id         = aws_route53_zone.public.zone_id
  records = [
    aws_route53_zone.public.name_servers[0],
    aws_route53_zone.public.name_servers[1],
    aws_route53_zone.public.name_servers[2],
    aws_route53_zone.public.name_servers[3],
  ]
}

# === Start of Authority Record ===
resource "aws_route53_record" "soa" {
  name            = local.fqdn
  allow_overwrite = true
  ttl             = 900
  type            = "SOA"
  zone_id         = aws_route53_zone.public.zone_id
  records = [
    "${aws_route53_zone.public.name_servers[2]}. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"
  ]
}

# === Guacamole Canonical Name Record ===
variable "dev_guacamole_elb" {
  default = "internal-guacamole-app-1899819619.us-east-1.elb.amazonaws.com"
}

# TODO, value needs to be updated
variable "prod_guacamole_elb" {
  default = ""
}

locals {
  guacamole_elb = var.common.environment == "dev" ? var.dev_guacamole_elb : var.prod_guacamole_elb
}

resource "aws_route53_record" "guacamole" {
  name            = "guacamole.${local.fqdn}"
  allow_overwrite = true
  ttl             = 300
  type            = "CNAME"
  zone_id         = aws_route53_zone.public.zone_id
  records = [local.guacamole_elb]
}

# === Portal API Canonical Name Record ===
resource "aws_route53_record" "portal_api" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "portal-api.${local.fqdn}"
  # type    = "A"
  type    = "CNAME"
  ttl     = 300
  records = ["${aws_api_gateway_rest_api.portal.id}.execute-api.${var.common.region}.amazonaws.com"]
  # records = [aws_api_gateway_stage.v1.invoke_url]
}

# === Portal Canonical Name Record ===
variable "dev_nginx_elb" {
  default = "internal-dev-nginx-load-balancer-429520900.us-east-1.elb.amazonaws.com"
}

# TODO, value needs to be updated
variable "prod_nginx_elb" {
  default = ""
}

locals {
  nginx_elb = var.common.environment == "dev" ? var.dev_nginx_elb : var.prod_nginx_elb
}

resource "aws_route53_record" "portal" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "portal.${local.fqdn}"
  type    = "CNAME"
  ttl     = 300
  records = [local.nginx_elb]
}

# === SFTP Canonical Name Record ===
variable "dev_transfer_server_url" {
  default = "s-17439e56624c4fbb9.server.transfer.us-east-1.amazonaws.com"
}

# TODO, value needs to be updated
variable "prod_transfer_server_url" {
  default = ""
}

locals {
  transfer_server_url = var.common.environment == "dev" ? var.dev_transfer_server_url : var.prod_transfer_server_url
}

resource "aws_route53_record" "sftp" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "sftp.${local.fqdn}"
  type    = "CNAME"
  ttl     = 300
  records = [local.transfer_server_url]
}


# ==== Test Subdomains ====
# === Sub1 (Test Portal) Canonical Name Record ===
resource "aws_route53_record" "sub1" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "sub1.${local.fqdn}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_cloudfront_distribution.portal.domain_name]
}

# === Sub2 (Test Portal API) Canonical Name Record ===
resource "aws_route53_record" "sub2" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "sub2.${local.fqdn}"
  type    = "CNAME"
  ttl     = 300
  records = ["${aws_api_gateway_rest_api.portal.id}.execute-api.${var.common.region}.amazonaws.com"]
}
