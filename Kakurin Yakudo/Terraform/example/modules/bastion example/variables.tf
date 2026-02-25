
variable "name" {
  description = "Name tag for the Bastion instance"
  type        = string
  default     = "gmst-bastion-ec2"
}

variable "instance_type" {
  description = "EC2 instance type for Bastion"
  type        = string
  default     = "t4g.large"
}

variable "vpc_id" {
  description = "VPC ID where Bastion will be created"
  type        = string
}

variable "subnet_id" {
  description = "Public subnet ID where Bastion will be placed"
  type        = string
}

variable "ssh_port" {
  description = "Custom SSH port (not 22)"
  type        = number
  default     = 2025
}

variable "key_pair_name" {
  description = "Key pair name for SSH access"
  type        = string
}
