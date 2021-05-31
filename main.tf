/*
 * Variables
 */

variable "region" {}
variable "domain" {}

variable "key_hash" {}
variable "acm_arn" {}

/*
 * Providers
 */

provider "aws" {}

/*
 * Configuration
 */

##
## S3 Bucket
##

resource "aws_s3_bucket" "wkd" {
  bucket = "openpgpkey.${var.domain}--wkd"
  acl    = "private"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3600
  }
}

##
## Upload Key & WKD Policy
##

resource "aws_s3_bucket_object" "policy" {
  bucket  = aws_s3_bucket.wkd.id
  key     = ".well-known/openpgpkey/${var.domain}/policy"
  content = ""
}

resource "aws_s3_bucket_object" "key" {
  bucket = aws_s3_bucket.wkd.id
  key    = ".well-known/openpgpkey/${var.domain}/hu/${var.key_hash}"
  source = "keys/${var.key_hash}"
  etag   = filemd5("keys/${var.key_hash}")
}

##
## CloudFront
##

resource "aws_cloudfront_distribution" "wkd" {
  origin {
    domain_name = aws_s3_bucket.wkd.bucket_regional_domain_name
    origin_id   = "s3"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.wkd.cloudfront_access_identity_path
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  aliases = ["openpgpkey.${var.domain}"]

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]

    target_origin_id = "s3"

    forwarded_values {
      query_string = false

      headers = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 3600
    default_ttl            = 3600
    max_ttl                = 3600
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    ssl_support_method  = "sni-only"
    acm_certificate_arn = var.acm_arn
  }
}

##
## CloudFront Access to S3
##

resource "aws_cloudfront_origin_access_identity" "wkd" {
  comment = "Access to wkd bucket"
}

data "aws_iam_policy_document" "wkd_s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.wkd.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.wkd.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "wkd" {
  bucket = aws_s3_bucket.wkd.id
  policy = data.aws_iam_policy_document.wkd_s3_policy.json
}
