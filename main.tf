terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "learn-terraform-aws-v2"
    workspaces {
      name = "Week-2"
    }
  }
}

# Provider
provider "aws" {
  region = "eu-west-1"
}

provider "aws" {
  region = "us-east-1"
  alias  = "n-virginia"
}

resource "aws_s3_bucket" "tech-blog" {
  bucket = "tech-blog-colin-best-devops"


}