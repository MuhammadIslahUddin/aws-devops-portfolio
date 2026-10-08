resource "aws_cognito_user_pool" "portfolio" {
  name = "portfolio-auth-pool"

  password_policy {
    minimum_length    = 8
    require_uppercase = true
    require_lowercase = true
    require_numbers   = true
  }

  auto_verified_attributes = ["email"]

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  tags = {
    Project   = "devops-portfolio"
    Stage     = "stage-2"
    ManagedBy = "Terraform"
  }
}

resource "aws_cognito_user_pool_client" "frontend" {
  name         = "frontend-client"
  user_pool_id = aws_cognito_user_pool.portfolio.id

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  callback_urls                = ["https://${aws_cloudfront_distribution.frontend.domain_name}"]
  logout_urls                  = ["https://${aws_cloudfront_distribution.frontend.domain_name}"]
  supported_identity_providers = ["COGNITO"]
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.portfolio.id
}

output "cognito_client_id" {
  value = aws_cognito_user_pool_client.frontend.id
}
