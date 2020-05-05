data "google_dns_managed_zone" "dns_zone" {
  name = var.dns_zone
}

resource "aws_acm_certificate" "cert" {
  domain_name       = var.dns_names[0]
  subject_alternative_names = slice(var.dns_names, 1, length(var.dns_names))
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn = aws_acm_certificate.cert.arn

  validation_record_fqdns = google_dns_record_set.validation.*.name
}

resource "google_dns_record_set" "validation" {
  count = length(var.dns_names)
  name = aws_acm_certificate.cert.domain_validation_options[count.index].resource_record_name
  type = aws_acm_certificate.cert.domain_validation_options[count.index].resource_record_type
  ttl  = 60

  managed_zone = data.google_dns_managed_zone.dns_zone.name

  rrdatas = [aws_acm_certificate.cert.domain_validation_options[count.index].resource_record_value]
}