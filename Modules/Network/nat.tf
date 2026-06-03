resource "aws_eip" "nat" {
  for_each = local.nat_subnets

  domain = "vpc"
}

resource "aws_nat_gateway" "production" {

  for_each = local.nat_subnets

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id
}