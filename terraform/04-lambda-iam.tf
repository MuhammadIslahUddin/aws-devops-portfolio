# IAM Role — Lambda execution
resource "aws_iam_role" "task_service" {
  name = "portfolio-task-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Project   = "devops-portfolio"
    Stage     = "stage-2"
    ManagedBy = "Terraform"
  }
}

# Least-privilege policy: CloudWatch logging + DynamoDB only
resource "aws_iam_role_policy" "task_service_permissions" {
  name = "task-service-policy"
  role = aws_iam_role.task_service.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:Scan",
          "dynamodb:GetItem"
        ]
        Resource = aws_dynamodb_table.tasks.arn
      }
    ]
  })
}
