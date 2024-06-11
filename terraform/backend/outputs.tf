output "resource_urls" {
  value = {
    portal     = aws_route53_record.portal.name
    portal_api = "${aws_route53_record.portal_api.name}/${aws_api_gateway_stage.v1.stage_name}"
    guacamole  = aws_route53_record.guacamole.name
    sftp       = aws_route53_record.sftp.name
    sub1       = aws_route53_record.sub1.name
    sub2       = "${aws_route53_record.sub2.name}/${aws_api_gateway_stage.v1.stage_name}"
  }
}

output "s3" {
  value = {
    portal = { bucket = aws_s3_bucket.portal.bucket }
  }
}
