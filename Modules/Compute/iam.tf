resource "aws_iam_role" "this" {

  name = "${var.project_name}-${var.environment}-role"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    Name        = "${var.project_name}-${var.environment}-role"
    Environment = var.environment
  }
}

resource "aws_iam_instance_profile" "this" {

  name = "${var.project_name}-${var.environment}-profile"

  role = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "managed" {

  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "custom" {

  for_each = var.custom_policies

  name   = each.key
  role   = aws_iam_role.this.id
  policy = each.value
}