terraform {
  backend "s3" {
    bucket         = "ak1-demo-01"
    key            = "nodejs-cicd/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
  }
}