provider "aws" {
  region = "us-east-1"
}

# Create a Cognito User Pool
resource "aws_cognito_user_pool" "user_pool" {
  name                = "UnicornRidesUserPool"
  alias_attributes    = ["email"]
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
    require_lowercase = true
  }
}

# Create a Cognito App Client
resource "aws_cognito_user_pool_client" "app_client" {
  name         = "UnicornRidesApp"
  user_pool_id = aws_cognito_user_pool.user_pool.id
  generate_secret = false

  allowed_oauth_flows          = ["code"]
  allowed_oauth_scopes         = ["email", "openid"]
  supported_identity_providers = ["COGNITO"]
}

# Create a DynamoDB table
resource "aws_dynamodb_table" "rides_table" {
  name         = "rides2024"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "rideID"
    type = "S"
  }

  hash_key = "rideID"

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name = "RidesTable"
  }
}

# Create an IAM role for Lambda function
resource "aws_iam_role" "lambda_role" {
  name               = "UnicornRidesLambdaRole"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "LambdaDynamoDBPolicy"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_dynamodb_policy.json
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_dynamodb_policy" {
  statement {
    actions   = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "dynamodb:UpdateItem"
    ]
    resources = [aws_dynamodb_table.rides_table.arn]
  }
  
  statement {
    actions   = ["logs:*"]
    resources = ["*"]  # Ideally, limit this to specific log group ARNs for production
  }
}

# Create the Lambda function
resource "aws_lambda_function" "request_unicorn" {
  function_name = "requestUnicorn"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"  # Adjust based on your function's entry point
  runtime       = "nodejs20.x"      # Use the appropriate runtime

  # Assuming the code is zipped and uploaded to S3
  s3_bucket     = var.lambda_code_s3_bucket
  s3_key        = var.lambda_code_s3_key

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.rides_table.name
    }
  }

  depends_on = [aws_iam_role_policy.lambda_policy]
}

# Create API Gateway REST API
resource "aws_api_gateway_rest_api" "api" {
  name        = "WildRidesAPI"
  description = "API for ride sharing application"
}

# Create a resource for rides
resource "aws_api_gateway_resource" "ride" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "ride"
}

# Create a POST method for the ride resource
resource "aws_api_gateway_method" "ride_post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.ride.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"

  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

# Create a Cognito authorizer for API Gateway
resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name                   = "CognitoAuthorizer"
  rest_api_id            = aws_api_gateway_rest_api.api.id
  identity_source        = "method.request.header.Authorization"
  provider_arns          = [aws_cognito_user_pool.user_pool.arn]
}

# Integrate the Lambda function with the API Gateway
resource "aws_api_gateway_integration" "ride_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.ride.id
  http_method             = aws_api_gateway_method.ride_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.request_unicorn.invoke_arn
}

# Deploy the API
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "dev"

  depends_on = [aws_api_gateway_integration.ride_integration]
}

# Outputs
output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.user_pool.id
}

output "api_endpoint" {
  value = "${aws_api_gateway_deployment.api_deployment.invoke_url}/ride"
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.rides_table.name
}
