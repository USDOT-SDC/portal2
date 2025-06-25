# === Public DNS Zone ===
data "aws_route53_zone" "public" {
  zone_id = var.route53_zone.public.id
}

# === Guacamole Name Record ===
locals {
  # Address in prod, else Canonical
  guac_type    = var.common.environment == "prod" ? "A" : "CNAME"
  guac_records = var.common.environment == "prod" ? ["192.168.0.1", "192.168.0.2"] : [module.guacamole.lb.dns_name]
}

resource "aws_route53_record" "guacamole" {
  name            = "guacamole.${var.fqdn}"
  zone_id         = data.aws_route53_zone.public.zone_id
  allow_overwrite = true
  type            = local.guac_type
  records         = local.guac_records
  ttl             = 300
}

# === Portal API Address Record ===
resource "aws_route53_record" "portal_api" {
  name    = "portal-api.${var.fqdn}"
  type    = "A"
  zone_id = data.aws_route53_zone.public.zone_id
  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.portal_api.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.portal_api.cloudfront_zone_id
  }
}

# === Portal Name Record ===
locals {
  # Address in prod, else Canonical
  dev_nginx_elb  = "internal-dev-nginx-load-balancer-429520900.us-east-1.elb.amazonaws.com"
  prod_nginx_elb = "internal-prod-nginx-load-balancer-539264498.us-east-1.elb.amazonaws.com"
  nginx_elb      = var.common.environment == "prod" ? local.prod_nginx_elb : local.dev_nginx_elb
  nginx_type     = var.common.environment == "prod" ? "A" : "CNAME"
  nginx_records  = var.common.environment == "prod" ? ["204.69.252.79", "204.69.252.59"] : [local.dev_nginx_elb]
}

resource "aws_route53_record" "portal" {
  name    = "portal.${var.fqdn}"
  zone_id = data.aws_route53_zone.public.zone_id
  type    = local.nginx_type
  records = local.nginx_records
  ttl     = 300
}

# === SFTP Canonical Name Record ===
locals {
  dev_transfer_server_url  = "s-17439e56624c4fbb9.server.transfer.us-east-1.amazonaws.com"
  prod_transfer_server_url = "s-7d17ff899e16432eb.server.transfer.us-east-1.amazonaws.com"
  transfer_server_url      = var.common.environment == "dev" ? local.dev_transfer_server_url : local.prod_transfer_server_url
}

resource "aws_route53_record" "sftp" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "sftp.${var.fqdn}"
  type    = "CNAME"
  ttl     = 300
  records = [local.transfer_server_url]
}

# ==== Test Subdomains ====
# === Sub1 (Test Portal) Canonical Name Record ===
resource "aws_route53_record" "sub1" {
  name    = "sub1.${var.fqdn}"
  type    = "CNAME"
  zone_id = data.aws_route53_zone.public.zone_id
  ttl     = 300
  records = [aws_cloudfront_distribution.portal.domain_name]
}

# === Sub2 (Test Portal API) Address Record ===
resource "aws_route53_record" "sub2" {
  name    = "sub2.${var.fqdn}"
  type    = "A"
  zone_id = data.aws_route53_zone.public.zone_id
  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.sub2.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.sub2.cloudfront_zone_id
  }
}
