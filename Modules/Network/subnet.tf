resource "aws_subnet" "public" {

  for_each = var.public_subnets

  vpc_id                  = aws_vpc.production.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${each.value.role}-${each.key}"
      Tier = "Public"
    }
  )
}

resource "aws_subnet" "private" {

  for_each = var.private_subnets

  vpc_id            = aws_vpc.production.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${each.value.role}-${each.key}"
      Tier = "Private"
    }
  )
}