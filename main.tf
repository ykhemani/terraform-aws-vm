terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  required_version = ">= 1.0"
}

locals {
  tags = merge(
    var.global_tags,
    var.local_tags
  )
}

provider "aws" {
  region = var.region
  default_tags {
    tags = local.tags
  }
}

data "terraform_remote_state" "foundation" {
  backend = "remote"

  config = {
    organization = var.org
    workspaces = {
      name = var.foundation_workspace
    }
  }
}

data "terraform_remote_state" "sg" {
  backend = "remote"

  config = {
    organization = var.org
    workspaces = {
      name = var.sg_workspace
    }
  }
}

data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_filter]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # Canonical
  owners = [var.ami_owner]
}

data "hcp_packer_iteration" "iteration" {
  bucket_name = var.hcp_packer_image_bucket_name
  channel     = var.hcp_packer_image_channel
}

data "hcp_packer_image" "image" {
  bucket_name    = var.hcp_packer_image_bucket_name
  cloud_provider = "aws"
  iteration_id   = data.hcp_packer_iteration.iteration.ulid
  region         = var.region
}

locals {
  # ami_id precedence:
  # 1. var.ami_id
  # 2. packer image
  # 3. aws_ami
  ami_id = var.ami_id != "" ? var.ami_id : (data.hcp_packer_image.image.cloud_image_id != "" ? data.hcp_packer_image.image.cloud_image_id : data.aws_ami.ami.id)
}

resource "aws_security_group" "sg_web" {
  name        = "web_ingress_sg"
  description = "${var.prefix} Web Ingress Security Group"
  vpc_id      = data.terraform_remote_state.foundation.outputs.vpc_id

  # http
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # https
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_ingress_sg"
  }
}

resource "aws_instance" "instance" {
  count                = var.instance_count
  subnet_id            = element(data.terraform_remote_state.foundation.outputs.public_subnets, count.index)
  ami                  = local.ami_id
  instance_type        = var.instance_type
  iam_instance_profile = var.iam_instance_profile
  vpc_security_group_ids = concat(
    [
      data.terraform_remote_state.sg.outputs.ingress_security_group_id,
      data.terraform_remote_state.sg.outputs.egress_security_group_id
    ],
    [aws_security_group.sg_web.id],
    var.instance_security_group_ids
  )
  key_name                    = var.ssh_key_name
  associate_public_ip_address = true
  root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size
  }

  #user_data                   = data.template_file.user_data.rendered

  tags = {
    Name = "${var.prefix}-demo"
    Demo = "Strategy Day"
  }
}
