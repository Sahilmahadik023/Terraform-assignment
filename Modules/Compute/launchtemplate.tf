resource "aws_launch_template" "this" {

  name_prefix = "${var.project_name}-${var.environment}-"

  image_id      = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = [
    var.security_group_id
  ]

  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }

user_data = base64encode(templatefile(
  "${path.module}/userdata.sh",
  {
    project_name = var.project_name
    environment  = var.environment
  }
))

 block_device_mappings {
    device_name = "/dev/xvda" # Root volume

    ebs {
      encrypted             = true
      volume_type           = "gp3"
      volume_size           = 20
      delete_on_termination = true

    }
  }
  tag_specifications {

    resource_type = "instance"

    tags = merge(
      var.common_tags,
      {
        Name = "${var.project_name}-${var.environment}-app"
      }
    )
  }
}