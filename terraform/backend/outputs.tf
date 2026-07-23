output "resource_urls" {
  value = {
    portal     = aws_route53_record.portal.name
    portal_api = "${aws_route53_record.portal_api.name}/${aws_api_gateway_stage.v1.stage_name}"
    guacamole  = aws_route53_record.guacamole.name
    sftp       = aws_route53_record.sftp.name
  }
}

output "s3" {
  value = {
    portal = { bucket = aws_s3_bucket.portal.bucket }
  }
}

output "api_gateway_deployment_hash_map" {
  value = local.api_gateway_deployment_hash_map
}

output "cognito" {
  value = module.cognito.cognito
}
