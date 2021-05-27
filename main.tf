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

resource "aws_s3_bucket" "wkd" {
  bucket = "openpgpkey.${var.domain}--wkd"
  acl    = "private"
}

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
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    target_origin_id = "s3"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 86400
    default_ttl            = 86400
    max_ttl                = 86400
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
