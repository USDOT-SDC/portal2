output "rest_api" {
  value = {
    id  = aws_api_gateway_rest_api.portal.id
    url = aws_api_gateway_stage.v1.invoke_url
  }
}

output "s3" {
  value = {
    portal_bucket = aws_s3_bucket.portal.id
  }
}
