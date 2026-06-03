resource "aws_route_table" "public" {
  vpc_id = aws_vpc.production.id

  # Default IGW route always present
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.production.id
  }

  # Any extra routes injected from root module
  dynamic "route" {
    for_each = var.public_routes
    content {
      cidr_block                = route.value.cidr_block
      gateway_id                = route.value.gateway_id
      nat_gateway_id            = route.value.nat_gateway_id
      vpc_peering_connection_id = route.value.vpc_peering_connection_id
      transit_gateway_id        = route.value.transit_gateway_id
    }
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-rt"
  })
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.production.id

  # Default NAT route always present
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = values(aws_nat_gateway.production)[0].id
  }

  # Any extra routes injected from root module
  dynamic "route" {
    for_each = var.private_routes
    content {
      cidr_block                = route.value.cidr_block
      gateway_id                = route.value.gateway_id
      nat_gateway_id            = route.value.nat_gateway_id
      vpc_peering_connection_id = route.value.vpc_peering_connection_id
      transit_gateway_id        = route.value.transit_gateway_id
    }
  }

  depends_on = [aws_nat_gateway.production]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-private-rt"
  })
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}