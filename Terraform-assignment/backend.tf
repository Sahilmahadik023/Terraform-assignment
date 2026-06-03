
terraform {
  backend "s3" {
    bucket         = "saas-production-tfstate"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "saas-production-tflock"
    encrypt        = true
  }
}