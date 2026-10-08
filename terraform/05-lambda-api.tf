# ==========================================
# Stage 2 — Lambda + API Gateway + Cognito Auth
# ==========================================

# Build Lambda zip from source
data "archive_file" "lambda_task_service" {
  type        = "zip"
  source_dir  = "../backend/functions/task-service"
  output_path = "../backend/functions/task-service.zip"
  excludes    = [".git/*", "*.md"]
}

# Lambda Function
resource "aws_lambda_function" "task_service" {
  function_name    = "portfolio-task-service"
  filename         = data.archive_file.lambda_task_service.output_path
  source_code_hash = data.archive_file.lambda_task_service.output_base64sha256
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.task_service.arn

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.tasks.name
      REGION         = var.aws_region
    }
  }

  tags = {
    Project   = "devops-portfolio"
    Stage     = "stage-2"
    ManagedBy = "Terraform"
  }
}

# HTTP API Gateway
resource "aws_apigatewayv2_api" "portfolio" {
  name          = "portfolio-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["https://${aws_cloudfront_distribution.frontend.domain_name}"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
  }
}

# Cognito JWT Authorizer
resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id           = aws_apigatewayv2_api.portfolio.id
  name             = "cognito-auth"
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    issuer   = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.portfolio.id}"
    audience = [aws_cognito_user_pool_client.frontend.id]
  }
}

# Lambda Integration
resource "aws_apigatewayv2_integration" "task_service" {
  api_id                 = aws_apigatewayv2_api.portfolio.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.task_service.invoke_arn
  payload_format_version = "2.0"
}

# Routes
resource "aws_apigatewayv2_route" "tasks_get" {
  api_id             = aws_apigatewayv2_api.portfolio.id
  route_key          = "GET /api/tasks"
  target             = "integrations/${aws_apigatewayv2_integration.task_service.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

resource "aws_apigatewayv2_route" "tasks_post" {
  api_id             = aws_apigatewayv2_api.portfolio.id
  route_key          = "POST /api/tasks"
  target             = "integrations/${aws_apigatewayv2_integration.task_service.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

# Deployment
resource "aws_apigatewayv2_deployment" "portfolio" {
  api_id = aws_apigatewayv2_api.portfolio.id

  depends_on = [
    aws_apigatewayv2_route.tasks_get,
    aws_apigatewayv2_route.tasks_post
  ]
}

# Stage
resource "aws_apigatewayv2_stage" "prod" {
  api_id        = aws_apigatewayv2_api.portfolio.id
  name          = "prod"
  deployment_id = aws_apigatewayv2_deployment.portfolio.id
}

# Grant API Gateway permission to invoke Lambda
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.task_service.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.portfolio.execution_arn}/*/*"
}

output "api_endpoint" {
  value = "${aws_apigatewayv2_api.portfolio.api_endpoint}/${aws_apigatewayv2_stage.prod.name}"
}
