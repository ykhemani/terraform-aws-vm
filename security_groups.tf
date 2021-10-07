################################################################################
# remote access from home
resource "aws_security_group" "sg_ingress" {
  name        = "${var.owner}_demo_ingress_sg"
  description = "${var.owner} Ingress Security Group"
  vpc_id      = data.terraform_remote_state.foundation.outputs.vpc_id

  # owner cidr blocks
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.owner_cidr_blocks
  }

  # vpc cidr block
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.terraform_remote_state.foundation.outputs.vpc_cidr_block]
  }

  // ingress {
  //   from_port   = 80
  //   to_port     = 80
  //   protocol    = "tcp"
  //   cidr_blocks = ["0.0.0.0/0"]
  // }
  //
  // ingress {
  //   from_port   = 443
  //   to_port     = 443
  //   protocol    = "tcp"
  //   cidr_blocks = ["0.0.0.0/0"]
  // }

  tags = {
    Owner = var.owner
    Name  = "${var.owner}_demo_ingress_sg"
  }
}

resource "aws_security_group" "sg_egress" {

  name        = "${var.owner}_demo_egress_sg"
  description = "${var.owner} Egress Security Group"
  vpc_id      = data.terraform_remote_state.foundation.outputs.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Owner = var.owner
    Name  = "${var.owner}_concourse_egress_sg"
  }
}
