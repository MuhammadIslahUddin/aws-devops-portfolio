
# ☁️ Cloud Native DevOps Portfolio

> **Industry-Grade AWS Project • Free Tier Eligible**
> Built with Terraform • S3 + CloudFront + Cognito + Lambda + DynamoDB + API Gateway

---

## 📍 Connect With Me

- **GitHub:** [github.com/MuhammadIslahUddin](https://github.com/MuhammadIslahUddin)
- **LinkedIn:** [linkedin.com/in/muhammad-islah-uddin-941335196](https://www.linkedin.com/in/muhammad-islah-uddin-941335196)
- **Email:** islah.uddin.56829@gmail.com

---

## 📋 Project Overview

A production-ready, secure serverless portfolio application demonstrating end-to-end AWS DevOps practices:

- ✅ **Static Website Hosting** — Private S3 bucket + CloudFront CDN with OAC
- ✅ **Authentication** — Amazon Cognito User Pool (JWT-based auth)
- ✅ **Serverless Backend** — AWS Lambda (Node.js 20.x)
- ✅ **RESTful API** — HTTP API Gateway with JWT authorization
- ✅ **NoSQL Database** — Amazon DynamoDB
- ✅ **Infrastructure as Code** — Fully managed by Terraform
- ✅ **Security** — Least-privilege IAM, encrypted at rest, no public bucket access

---

## 🏗️ Architecture Diagram

[User] → [CloudFront (SSL/CDN)] → [Private S3 Bucket]
↓
[Cognito Login]
↓
[Frontend] → [API Gateway (JWT Authorizer)] → [Lambda Function]
↓
[DynamoDB Table]
plaintext

---

## 📁 Repository Structure

aws-devops-portfolio/
├── terraform/
│ ├── providers.tf # AWS + Random + Archive providers
│ ├── variables.tf # Region & common variables
│ ├── outputs.tf # Deployment URLs & IDs
│ ├── 01-frontend.tf # S3 + CloudFront + OAC
│ ├── 02-cognito.tf # User Pool + App Client
│ ├── 03-dynamodb.tf # Tasks table definition
│ ├── 04-lambda-iam.tf # IAM Role + DynamoDB permissions
│ └── 05-lambda-api.tf # Lambda + API Gateway + Routes
├── frontend/
│ ├── dist/
│ │ └── index.html # Portfolio UI
│ └── public/
├── backend/
│ └── functions/
│ └── task-service/
│ ├── index.js # Lambda handler
│ ├── package.json
│ └── node_modules/
├── .gitignore
├── README.md
└── LICENSE
plaintext

---

## 🚀 Quick Deployment

### Prerequisites
- AWS Account (Free Tier eligible)
- Ubuntu / WSL2
- Terraform ≥ 1.6
- AWS CLI configured with credentials

### Deploy
```bash
# Clone & enter
git clone https://github.com/MuhammadIslahUddin/aws-devops-portfolio.git
cd aws-devops-portfolio/terraform

# Initialize
terraform init
terraform fmt -recursive
terraform validate

# Review plan
terraform plan

# Deploy
terraform apply
# Enter: yes
Outputs
After successful deployment you will get:
plaintext
api_endpoint          = "https://xxxxxx.execute-api.us-east-1.amazonaws.com/prod"
cloudfront_domain     = "https://xxxxxx.cloudfront.net"
cognito_client_id     = "xxxxxxxxxxxxxxxxxxxxxxxxxx"
cognito_user_pool_id  = "us-east-1_XXXXXXXXXXX"
dynamodb_table_name   = "portfolio-tasks"
frontend_bucket_name  = "devops-portfolio-frontend-xxxxxx"
🔧 Key Features Explained

1. Frontend Hosting
Private S3 Bucket — No public access allowed
CloudFront OAC — Only CloudFront can access the bucket
HTTPS Only — Automatic redirects, TLS 1.2+
Cost Control — Free Tier eligible

2. Authentication
Cognito User Pool — Secure email/password auth
JWT Tokens — ID/Access tokens stored in browser
API Authorization — Every request validated at API Gateway

3. Backend API
Lambda — Node.js 20.x, on-demand execution
HTTP API Gateway — Low-latency, cost-effective endpoints
DynamoDB — Serverless NoSQL, auto-scaling
IAM Least Privilege — Lambda can ONLY read/write its own table
🧪 Testing the API
bash

# Get all tasks (requires Authorization header)
curl -H "Authorization: Bearer <ID_TOKEN>" \
  https://<API_ID>.execute-api.us-east-1.amazonaws.com/prod/api/tasks

# Create task
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <ID_TOKEN>" \
  -d '{"title":"My Task"}' \
  https://<API_ID>.execute-api.us-east-1.amazonaws.com/prod/api/tasks
🧹 Cleanup / Delete Resources
To avoid charges, destroy infrastructure when not in use:
bash
cd terraform
terraform destroy
# Enter: yes
All resources are removed — nothing remains in your AWS account.

💰 Cost & Free Tier
Table
Service	Free Tier Coverage
S3	5 GB storage • 12 months
CloudFront	1 TB data transfer • always free
Lambda	1M requests/month • always free
DynamoDB	25 GB + 2.5M reads/writes • always free
API Gateway	1M requests/month • 12 months
Cognito	50,000 monthly active users • always free
Recommendation: Set AWS Budget Alerts at $0.01/month as safety net.

📝 Next Steps & TODO
 Fix Lambda dependency bundling for clean 500→200 resolution
 Custom domain via Route 53
 GitHub Actions CI/CD pipeline (terraform plan/apply on push)
 Unit tests for Lambda functions
 Task editing & deletion endpoints
 Add monitoring: CloudWatch Alarms + X-Ray tracing

📧 Author
Muhammad Islah Uddin
GitHub: @MuhammadIslahUddin
LinkedIn: Connect with me
Email: islah.uddin.56829@gmail.com

"Building secure, scalable, cost-effective cloud infrastructure"
