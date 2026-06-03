resource "aws_internet_gateway" "production" {

  vpc_id = aws_vpc.production.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-igw"
    }
  )
}