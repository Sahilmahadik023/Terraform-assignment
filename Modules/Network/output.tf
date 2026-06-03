output "vpc_id" {
  value = aws_vpc.production.id
}



output "public_subnet_ids" {
  value = { for k, v in aws_subnet.public : k => v.id }
}

output "private_subnet_ids" {
  value = { for k, v in aws_subnet.private : k => v.id }
}

output "nat_gateway_ids" {
  value = { for k, v in aws_nat_gateway.production : k => v.id }
}