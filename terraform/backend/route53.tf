data "aws_route53_zone" "primary" {
  name = "sdc-dev.dot.gov."
}


# resource "aws_route53_record" "api" {
#   zone_id = data.aws_route53_zone.primary.zone_id
#   name    = "portal-api.${data.aws_route53_zone.primary.name}"
#   type    = "A"

#   alias {
#     name                   = aws_api_gateway_stage.v1.invoke_url
#     zone_id                = data.aws_route53_zone.primary.zone_id
#     evaluate_target_health = true
#   }
# }
