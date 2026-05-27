resource "aws_acm_certificate" "regional" {
  domain_name = var.backend_domain

  subject_alternative_names = [
    var.frontend_origin_domain
  ]

  validation_method = "DNS"

  tags = merge(var.common_tags, {
    Name = "cure-regional-alb-certificate"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "regional_validation" {
  for_each = {
    for dvo in aws_acm_certificate.regional.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = var.root_zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "regional" {
  certificate_arn         = aws_acm_certificate.regional.arn
  validation_record_fqdns = [for record in aws_route53_record.regional_validation : record.fqdn]
}

resource "aws_acm_certificate" "cloudfront" {
  provider = aws.us_east_1

  domain_name       = var.frontend_domain
  validation_method = "DNS"

  tags = merge(var.common_tags, {
    Name = "cure-cloudfront-certificate"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cloudfront_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cloudfront.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = var.root_zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "cloudfront" {
  provider = aws.us_east_1

  certificate_arn         = aws_acm_certificate.cloudfront.arn
  validation_record_fqdns = [for record in aws_route53_record.cloudfront_validation : record.fqdn]
}
