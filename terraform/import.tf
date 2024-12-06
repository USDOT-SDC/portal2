# import {
#   to = module.be.aws_route53_zone.public
#   id = "Z103672221FNFH7O9E9OG"
# }

# import {
#   to = module.be.aws_iam_role.webportal_lambda
#   id = "platform.lambda.portal2.be.role"
# }

# import {
#   to = module.be.aws_route53_record.ns
#   id = "Z103672221FNFH7O9E9OG_sdc-dev.dot.gov_NS"
# }

# import {
#   to = module.be.aws_route53_record.soa
#   id = "Z103672221FNFH7O9E9OG_sdc-dev.dot.gov_SOA"
# }

# import {
#   to = module.be.aws_route53_record.guacamole
#   id = "Z103672221FNFH7O9E9OG_guacamole.sdc-dev.dot.gov_CNAME"
# }

# import {
#   to = module.be.aws_route53_record.portal_api
#   id = "Z103672221FNFH7O9E9OG_portal-api.sdc-dev.dot.gov_CNAME"
# }

# import {
#   to = module.be.aws_route53_record.portal
#   id = "Z103672221FNFH7O9E9OG_portal.sdc.dot.gov_CNAME"
# }

# import {
#   to = module.be.aws_route53_record.sftp
#   id = "Z103672221FNFH7O9E9OG_sftp.sdc-dev.dot.gov_CNAME"
# }

# import {
#   to = module.be.aws_cloudfront_distribution.portal
#   id = "E16BWGUA8YO3CX"
# }

# import {
#   to = module.be.aws_cloudfront_origin_access_control.portal
#   id = "E2PSKEPV2RCMK7"
# }

# import {
#   to = module.be.aws_api_gateway_resource.health
#   id = "hdvvw7yfy4/8k6c5b"
# }

# import {
#   to = module.be.aws_api_gateway_method.health_any
#   id = "hdvvw7yfy4/8k6c5b/ANY"
# }

# import {
#   to = module.be.aws_api_gateway_integration.health_any_mock
#   id = "hdvvw7yfy4/8k6c5b/ANY"
# }

# import {
#   to = module.be.aws_api_gateway_method_response.health_any_200
#   id = "hdvvw7yfy4/8k6c5b/ANY/200"
# }

# import {
#   to = module.be.aws_api_gateway_integration_response.health_any_200
#   id = "hdvvw7yfy4/8k6c5b/ANY/200"
# }

# === Old Cognito ===
# import {
#   to = module.be.module.cognito_old.aws_cognito_user_pool.old
#   id = "us-east-1_sNIwupW53"
# }

# import {
#   to = module.be.module.cognito_old.aws_cognito_user_pool_client.old_login_gov
#   id = "us-east-1_sNIwupW53/122lj1qh9e5qam3u29fpdt9ati"
# }

# import {
#   to = module.be.module.cognito_old.aws_cognito_user_pool_client.old_active_directory
#   id = "us-east-1_sNIwupW53/6s90hhstst6td8sdo1ntl3laet"
# }

# import {
#   to = module.be.module.cognito_old.aws_cognito_user_pool_client.old_sdc_dot
#   id = "us-east-1_sNIwupW53/7qoe2cb1jb3oc1oj0ari25h3sk"
# }

# import {
#   to = module.be.module.cognito_old.aws_cognito_identity_provider.old_dot_ad
#   id = "us-east-1_sNIwupW53:dev-dot-ad"
# }

# import {
#   to = module.be.module.cognito_old.aws_cognito_identity_provider.old_login_gov
#   id = "us-east-1_sNIwupW53:dev-pvt-login-gov-lambda-proxy"
# }

# import {
#   to = module.be.module.cognito_old.aws_cognito_identity_provider.old_usdot_adfs
#   id = "us-east-1_sNIwupW53:USDOT-ADFS"
# }

