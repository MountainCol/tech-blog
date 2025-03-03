terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    token        = "token_placeholder"
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

###############
## Variables ##
###############

variable "domain_name" {
  description = "Domain name for the blog"
  type        = string
  default     = "http://cloudtalent-blog-bucket1234.s3-website-eu-west-1.amazonaws.com"
}

###############################
## Bucket for static website ##
###############################

# Bucket Config
# Get the existing S3 bucket
data "aws_s3_bucket" "existing_bucket" {
  bucket = "cloudtalent-blog-bucket1234"
}

# Get the CloudFront distribution
data "aws_cloudfront_distribution" "cdn" {
  id = "E2C7O8WN0508EP"
}

# Create the bucket policy
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = data.aws_s3_bucket.existing_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action = [
          "s3:GetObject",
        ]
        Resource = [
          "${data.aws_s3_bucket.existing_bucket.arn}/*",
          data.aws_s3_bucket.existing_bucket.arn
        ]
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = data.aws_cloudfront_distribution.cdn.arn
            
          }
        }
      },
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${data.aws_s3_bucket.existing_bucket.arn}/*"
      }
    ]
  })
}

# Optional: Make sure the bucket allows public access
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = data.aws_s3_bucket.existing_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
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
