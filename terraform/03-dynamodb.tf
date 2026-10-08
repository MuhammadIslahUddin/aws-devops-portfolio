resource "aws_dynamodb_table" "tasks" {
  name         = "portfolio-tasks"
  billing_mode = "PAY_PER_REQUEST" # On-demand — no over-provisioning surprises
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Project   = "devops-portfolio"
    Stage     = "stage-2"
    ManagedBy = "Terraform"
  }
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.tasks.name
}

