terraform {
  required_version = "~> 1.0" 

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.2.0"
    }
  }
  
  backend "s3" {
    bucket         = "abdikarimh-state-bucket"
    key            = "terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform_locks"
  }
}