provider "aws" {
  region = var.region
}

data "terraform_remote_state" "foundation" {
  backend = "remote"
  config = {
    organization = "khemani"
    workspaces = {
      name = "demo-terraform-aws-foundation"
    }
  }
}

data "aws_ami" "ubuntu" {
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

locals {
  ami_id = var.ami_id == "" ? data.aws_ami.ubuntu.id : var.ami_id
}

resource "aws_instance" "instance" {
  count                       = var.instance_count
  subnet_id                   = element(data.terraform_remote_state.foundation.outputs.public_subnets, count.index)
  ami                         = var.ami_id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.sg_ingress.id, aws_security_group.sg_egress.id]
  key_name                    = var.ssh_key_name
  associate_public_ip_address = true
  root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size
  }

  #user_data                   = data.template_file.user_data.rendered

  tags = {
    owner      = var.owner
    ttl        = var.ttl
    Name       = "${var.owner}-demo"
    Image_Name = local.ami_id

    se-region          = var.se-region
    purpose            = var.purpose
    terraform          = "true"
    hc-internet-facing = var.hc-internet-facing
    creator            = var.creator
    customer           = var.customer
    tfe-workspace      = var.tfe-workspace
    lifecycle-action   = var.lifecycle-action
    config-as-code     = var.config-as-code
    repo               = var.repo

  }
}
