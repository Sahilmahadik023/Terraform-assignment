

output "domain_validation_options" {
  value = aws_acm_certificate.this.domain_validation_options
}

output "certificate_arn" {
  value = aws_acm_certificate_validation.this.certificate_arn
}