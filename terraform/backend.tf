terraform {
  backend "s3" {
    bucket         = "ak-backend-tf-bucket"
    key            = "nodejs-cicd/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
  }
}