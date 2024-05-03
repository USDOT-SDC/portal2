locals {
  s3_origin_id = "sdc.dot.gov.platform.portal"
}

resource "aws_cloudfront_distribution" "portal" {
  enabled = true
  comment = "Portal 2"
  aliases = ["dev-portal-ecs-sdc.dot.gov"]
  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    cache_policy_id        = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    compress               = true
  }
  default_root_object = "index.html"
  http_version        = "http2and3"
  origin {
    domain_name              = aws_s3_bucket.portal.bucket_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.portal.id
    origin_id                = local.s3_origin_id
  }
  price_class = "PriceClass_100"
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["AU", "NZ", "UM", "US", "GB", "CA", "IL"] # The Five Eyes (FVEY) + Israel
    }
  }
  tags = local.ecs_tags
  viewer_certificate {
    acm_certificate_arn            = "arn:aws:acm:us-east-1:505135622787:certificate/907238e5-e4fd-4a45-becf-743289908c11"
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
  web_acl_id          = "arn:aws:wafv2:us-east-1:505135622787:global/webacl/FMManagedWebACLV2-Enable-Shield-Advanced-Global-Policy-1681826198080/81323598-c0ec-4d6e-8690-95c47433d82e"
  retain_on_delete    = true  # Disables instead of deletes when destroying through Terraform. If set, needs to be deleted manually afterwards.
  wait_for_deployment = false # If enabled, the resource will wait for the distribution status to change from InProgress to Deployed.
}

resource "aws_cloudfront_origin_access_control" "portal" {
  name                              = "portal"
  description                       = "Portal Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "no-override"
  signing_protocol                  = "sigv4"
}
