# === Public DNS Zone ===
data "aws_route53_zone" "public" {
  zone_id = var.route53_zone.public.id
}

# === Guacamole Canonical Name Record ===
locals {
  dev_guacamole_elb  = "internal-guacamole-app-1899819619.us-east-1.elb.amazonaws.com"
  prod_guacamole_elb = "internal-prod-guacamole-load-balancer-923347317.us-east-1.elb.amazonaws.com"
  guacamole_elb      = var.common.environment == "dev" ? local.dev_guacamole_elb : local.prod_guacamole_elb
}

resource "aws_route53_record" "guacamole" {
  name            = "guacamole.${var.fqdn}"
  allow_overwrite = true
  ttl             = 300
  type            = "CNAME"
  zone_id         = data.aws_route53_zone.public.zone_id
  records         = [local.guacamole_elb]
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

# === Portal Canonical Name Record ===
locals {
  dev_nginx_elb  = "internal-dev-nginx-load-balancer-429520900.us-east-1.elb.amazonaws.com"
  prod_nginx_elb = "internal-prod-nginx-load-balancer-539264498.us-east-1.elb.amazonaws.com"
  nginx_elb      = var.common.environment == "dev" ? local.dev_nginx_elb : local.prod_nginx_elb
}

resource "aws_route53_record" "portal" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "portal.${var.fqdn}"
  type    = "CNAME"
  ttl     = 300
  records = [local.nginx_elb]
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
