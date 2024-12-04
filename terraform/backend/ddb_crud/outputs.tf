output "deployment_hash" {
  value = sha1(
    jsonencode(
      {
        r = aws_api_gateway_resource.ddb_crud

        m_options = aws_api_gateway_method.options
        m_post    = aws_api_gateway_method.post
        m_get     = aws_api_gateway_method.get
        m_put     = aws_api_gateway_method.put
        m_delete  = aws_api_gateway_method.delete

        i_options = aws_api_gateway_integration.options
        i_post    = aws_api_gateway_integration.post
        i_get     = aws_api_gateway_integration.get
        i_put     = aws_api_gateway_integration.put
        i_delete  = aws_api_gateway_integration.delete

        mr_options = aws_api_gateway_method_response.options
        mr_post    = aws_api_gateway_method_response.post
        mr_get     = aws_api_gateway_method_response.get
        mr_put     = aws_api_gateway_method_response.put
        mr_delete  = aws_api_gateway_method_response.delete

        ir_options = aws_api_gateway_integration_response.options
      }
    )
  )
}
