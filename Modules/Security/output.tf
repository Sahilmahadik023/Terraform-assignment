output "sg_id" {
  description = "Security group ID"
  value       = aws_security_group.Production.id
}

output "sg_name" {
  value = aws_security_group.Production.name
}