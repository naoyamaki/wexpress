resource "aws_route53_zone" "wexpress" {
  name = var.domain-name
  tags = {
    Name    = "${var.environment}-${var.service-name}"
  }
}

resource "aws_acm_certificate" "wexpress" {
  validation_method = "DNS"
  domain_name       = aws_route53_zone.wexpress.name

  subject_alternative_names = [
    "*.${aws_route53_zone.wexpress.name}"
  ]
  tags = {
    Name    = "${var.environment}-${var.service-name}"
  }
  depends_on = [ aws_route53_zone.wexpress ]
}

resource "aws_route53_record" "wexpress" {
  for_each = {
    for dvo in aws_acm_certificate.wexpress.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.wexpress.zone_id
  depends_on = [ aws_acm_certificate.wexpress ]
}
