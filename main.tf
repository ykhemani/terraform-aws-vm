terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  required_version = ">= 0.13"
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
