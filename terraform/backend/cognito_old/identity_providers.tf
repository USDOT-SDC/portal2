resource "aws_cognito_identity_provider" "old_dot_ad" {
  user_pool_id  = aws_cognito_user_pool.old.id
  provider_name = "dev-dot-ad"
  provider_type = "SAML"
  attribute_mapping = {
    "email" = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
  }
  idp_identifiers = []
  provider_details = {
    "ActiveEncryptionCertificate" = "MIICvDCCAaSgAwIBAgIId4ZiUri646swDQYJKoZIhvcNAQELBQAwHjEcMBoGA1UEAwwTdXMtZWFzdC0xX3NOSXd1cFc1MzAeFw0yNDAxMDQxNzE1MTNaFw0zNDAxMDQwMzI3MTNaMB4xHDAaBgNVBAMME3VzLWVhc3QtMV9zTkl3dXBXNTMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDybJwcV6WI9njZ7uT6QmVDdeeXpT+3erKS28X5Wh2Jh+z7vBnn8Bt1oXssglAKsk9zf9g/HJGy1dXNcH84bjsN494Bj58B9MoOA1XioQmDLofFD0TE9sJ6+UQyBLRhOfnoOtveILSLnmXU9mPrZRAmGcCAk3UZAyA+QMS1THsIzF1MhKDqDTEh/7c8mbyWMs8igMNAs+7mmAYI/ww61jixBZ9L9IGHj8jlb/DjaM266tW5Gg3g+nKVe/JgICU3GwIaW4XctJPO6W5l726CKWaCSvaGuJExNbvvSvRg6Y7dmwp0kMmzcHl5AJJOxcfmnhr0PdVzk9FsTQbl6NgZXVj1AgMBAAEwDQYJKoZIhvcNAQELBQADggEBANQCpCN0Xsuz98oGbGoJb4prs4whvuJFkjwY8fjfWFndMeeLyjmFiedsmqRvLPVNX3woL3M7NDWVkQ8eVtePIZ+QRYEWmEcOxzTBbavrq0qJsJQscXLkFZ4KBGT2EIWCxrQPBvLYqfUgrIyglInmJvzcaVXAcE25UIa8gK+jULQIDyz+6PTSS/YBb8cERK0r3TMliGL2gpJ2iYoP+8fLJOuAaldDXpLpf/iJaoAX++UUPQJlMNtJ1C34401PRfGniE0NKd85D8aTHBG+eNBEkhJtj8iYfpdYr96msFry3ElMyGaWprBNSVl4Okdd1PNR2Ss9thG/N/yPiYcTT6oBbP4="
    "IDPSignout"                  = "false"
    "MetadataFile"                = file("./backend/cognito_old/identity_provider_dot_ad_metadata.xml")
    "SLORedirectBindingURI"       = "https://adfs.dot.gov/adfs/ls/"
    "SSORedirectBindingURI"       = "https://adfs.dot.gov/adfs/ls/"
  }
}

resource "aws_cognito_identity_provider" "old_login_gov" {
  user_pool_id  = aws_cognito_user_pool.old.id
  provider_name = "dev-pvt-login-gov-lambda-proxy"
  provider_type = "OIDC"
  attribute_mapping = {
    "email"    = "email"
    "username" = "sub"
  }
  idp_identifiers = []
  provider_details = {
    "attributes_request_method"     = "GET"
    "attributes_url"                = "https://portal.sdc-dev.dot.gov/login-gov-proxy-dev/dev-login-gov-get-user-info"
    "attributes_url_add_attributes" = "false"
    "authorize_scopes"              = "openid email"
    "authorize_url"                 = "https://portal.sdc-dev.dot.gov/login-gov-proxy-dev/dev-login-gov-start-authorize"
    "client_id"                     = "urn:gov:gsa:openidconnect:openid:sdcdev"
    "jwks_uri"                      = "https://portal.sdc-dev.dot.gov/login-gov-proxy-dev/dev-login-gov-jwks-url"
    "oidc_issuer"                   = "https://portal.sdc-dev.dot.gov"
    "token_url"                     = "https://portal.sdc-dev.dot.gov/login-gov-proxy-dev/dev-login-gov-get-tokens"
  }
}

resource "aws_cognito_identity_provider" "old_usdot_adfs" {
  user_pool_id  = aws_cognito_user_pool.old.id
  provider_name = "USDOT-ADFS"
  provider_type = "SAML"
  attribute_mapping = {
    "email"       = "https://aws.amazon.com/SAML/Attributes/RoleSessionName"
    "family_name" = "https://aws.amazon.com/SAML/Attributes/Role"
  }
  idp_identifiers = []
  provider_details = {
    "ActiveEncryptionCertificate" = "MIICvDCCAaSgAwIBAgIIO0Y/osj+A+cwDQYJKoZIhvcNAQELBQAwHjEcMBoGA1UEAwwTdXMtZWFzdC0xX3NOSXd1cFc1MzAeFw0yNDA0MDkyMjMzNTNaFw0zNDA0MTAwODQ1NTNaMB4xHDAaBgNVBAMME3VzLWVhc3QtMV9zTkl3dXBXNTMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCrojNhEtjjn30Oh9sTPcjZ/rY/uWuQTeX1C+dEHbR+2NmQ1iQXpAcZhlYpG50psD30alrx0Kfh9Qx/zywk0qNwrPMNXrMvIDvjhs1njdxXL94HDuyZYvZFJ6CDD6FzhCojC9nzwlCdu3LQFcu3svFBcXC/y0WEWOuPOCqqziyhG5Uq2eaaVAkg17Ui9Q8ZUTRPOUAXWAaeg7F8iUt5GlUq/fR6J3RUdwt2vUcH69BgmopRWZhltunuX8RzscPL4ZCQtSon+E4A9Tpub6ggX+ILABg8U0x0DK0LZoscs6SFEgYp5g1St6T798GMmn9xEGSH6mKPhuzOTLg2n8838CUjAgMBAAEwDQYJKoZIhvcNAQELBQADggEBAGXN76YTH3OFkMy64azIiRNFHRpdvN/sW1KCcD8O7YBDT6zaWuIUre+gizlSJMHPIfNpgZ0gYc+u68J7kv63rHCBWRFxUU6KW3RyAjvxASLHkRhBNayJRU6SUzZv7/FgdWniBeNnGxYKYGxn0ntlJWUcEs0oQf+6TUeW+zL1i1X2G3cfYemEAFufELTItkRwNPrR0DF4xqWLEAOyceil7vdmwtsue8H1ECd3guHG8z9xf14ZZLdE4hWBcpD2gTQLKMbayAb3ZITGbUI8So3AHrSukOnVHvnKbrOjpp6AQ3CxGBNTbh8JpgQTnHX9WQFehyc5iYrTgoLctLjDcDiqjKQ="
    "IDPSignout"                  = "false"
    "MetadataFile"                = file("./backend/cognito_old/identity_provider_usdot_adfs_metadata.xml")
    "SLORedirectBindingURI"       = "https://adfs.dot.gov/adfs/ls/"
    "SSORedirectBindingURI"       = "https://adfs.dot.gov/adfs/ls/"
  }
}
