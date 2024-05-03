locals {
  s3_origin_id = "sdc.dot.gov.platform.portal"
}

resource "aws_cloudfront_distribution" "portal" {
  origin {
    domain_name              = aws_s3_bucket.portal.bucket_domain_name
    # domain_name              = "to-delete-webportal.s3.us-east-1.amazonaws.com"
    origin_access_control_id = aws_cloudfront_origin_access_control.portal.id
    origin_id                = local.s3_origin_id
  }

  enabled         = true
  is_ipv6_enabled = true
  #   comment             = "Some comment"
  default_root_object = "index.html"

  #   logging_config {
  #     include_cookies = false
  #     bucket          = "mylogs.s3.amazonaws.com"
  #     prefix          = "myprefix"
  #   }

  aliases = ["dev-portal-ecs-sdc.dot.gov"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    # forwarded_values {
    #   query_string = false

    #   cookies {
    #     forward = "none"
    #   }
    # }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    cache_policy_id        = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    compress               = true

    # function_association {
    #   event_type   = "viewer-request"
    #   function_arn = "arn:aws:cloudfront::505135622787:function/webportal-test-brandon"
    # }

  }

  #   # Cache behavior with precedence 0
  #   ordered_cache_behavior {
  #     path_pattern     = "/content/immutable/*"
  #     allowed_methods  = ["GET", "HEAD", "OPTIONS"]
  #     cached_methods   = ["GET", "HEAD", "OPTIONS"]
  #     target_origin_id = local.s3_origin_id

  #     forwarded_values {
  #       query_string = false
  #       headers      = ["Origin"]

  #       cookies {
  #         forward = "none"
  #       }
  #     }

  #     min_ttl                = 0
  #     default_ttl            = 86400
  #     max_ttl                = 31536000
  #     compress               = true
  #     viewer_protocol_policy = "redirect-to-https"
  #   }

  #   # Cache behavior with precedence 1
  #   ordered_cache_behavior {
  #     path_pattern     = "/content/*"
  #     allowed_methods  = ["GET", "HEAD", "OPTIONS"]
  #     cached_methods   = ["GET", "HEAD"]
  #     target_origin_id = local.s3_origin_id

  #     forwarded_values {
  #       query_string = false

  #       cookies {
  #         forward = "none"
  #       }
  #     }

  #     min_ttl                = 0
  #     default_ttl            = 3600
  #     max_ttl                = 86400
  #     compress               = true
  #     viewer_protocol_policy = "redirect-to-https"
  #   }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  #   restrictions {
  #     geo_restriction {
  #       restriction_type = "whitelist"
  #       locations        = ["US", "CA", "GB", "DE"]
  #     }
  #   }

  tags = local.ecs_tags

  #   viewer_certificate {
  #     cloudfront_default_certificate = true
  #   }

  viewer_certificate {
    acm_certificate_arn            = "arn:aws:acm:us-east-1:505135622787:certificate/907238e5-e4fd-4a45-becf-743289908c11"
    cloudfront_default_certificate = false
    iam_certificate_id             = null
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  web_acl_id = "arn:aws:wafv2:us-east-1:505135622787:global/webacl/FMManagedWebACLV2-Enable-Shield-Advanced-Global-Policy-1681826198080/81323598-c0ec-4d6e-8690-95c47433d82e"

}

resource "aws_cloudfront_origin_access_control" "portal" {
  name                              = "portal"
  description                       = "Portal Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "no-override"
  signing_protocol                  = "sigv4"
}
