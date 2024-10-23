output "user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.user_pool.id
}

output "user_pool_client_id" {
  description = "Cognito User Pool Client ID"
  value       = aws_cognito_user_pool_client.app_client.id
}

output "api_gateway_url" {
  description = "API Gateway URL for the ride endpoint"
  value       = "${aws_api_gateway_deployment.api_deployment.invoke_url}/ride"
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.rides_table.name
}
