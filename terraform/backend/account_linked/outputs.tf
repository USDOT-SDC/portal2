output "deployment_hash" {
  value = sha1(
    jsonencode(
      {
        r   = aws_api_gateway_resource.r
        m   = aws_api_gateway_method.m
        om  = aws_api_gateway_method.om
        i   = aws_api_gateway_integration.i
        oi  = aws_api_gateway_integration.oi
        mr  = aws_api_gateway_method_response.mr
        omr = aws_api_gateway_method_response.omr
        oir = aws_api_gateway_integration_response.oir
      }
    )
  )
}
