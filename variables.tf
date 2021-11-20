variable "region" {
  type        = string
  description = "AWS Region in which to deploy our instance."
  default     = "us-east-1"
}

variable "org" {
  type        = string
  description = "Terraform Cloud/Enterprise Organization Name"
}

variable "prefix" {
  type        = string
  description = "Naming prefix"
}

variable "foundation_workspace" {
  type        = string
  description = "Name of workspace from which to get information on VPC in which to provision resources."
}

variable "sg_workspace" {
  type        = string
  description = "Name of workspace from which to get foundational security groups to use."
}

variable "ami_filter" {
  type        = string
  description = "AMI filter - e.g. ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
  default     = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
}

variable "ami_owner" {
  type        = string
  description = "Owner of AMI - e.g. 099720109477"
  default     = "099720109477"
}

variable "ami_id" {
  type        = string
  description = "Optional AMI ID - use this if not blank string, otherwise use AMI per ami_filter and ami_owner."
  default     = ""
}

variable "instance_count" {
  type        = number
  description = "Number of instances to provision."
  default     = 1
}

variable "instance_type" {
  type        = string
  description = "Instance size."
  default     = "t2.medium"
}

variable "root_volume_type" {
  type        = string
  description = "Root volume type."
  default     = "gp2"
}

variable "root_volume_size" {
  type        = number
  description = "Root volume size in GB."
  default     = 50
}

variable "ssh_key_name" {
  type        = string
  description = "Name of SSH key in AWS region."
}

variable "owner_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks that will be allowed to access our instance."
  default     = ["0.0.0.0/0"]
}
