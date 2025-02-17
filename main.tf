terraform {
  backend "remote" {
    hostname = "app.terraform.io"
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
  alias = "n-virginia"
}

###############
## Variables ##
###############

variable "domain_name" {
  description = "Domain name for the blog"
  type        = string
  default     = "colinh.cloudtalents.io"
}

###############################
## Bucket for static website ##
###############################

# Bucket Config

resource "aws_s3_bucket" "tech-blog" {
  bucket = "cloudtalent-blog-bucket1234"

}

######################################
## Route 53 and Certificate Manager ##
######################################

resource "aws_route53_zone" "zone" {
  name = var.domain_name
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "colinh.cloudtalents.io"
  validation_method = "DNS"

  tags = {
    Environment = "test"
  }

  lifecycle {
    create_before_destroy = true
  }
}
