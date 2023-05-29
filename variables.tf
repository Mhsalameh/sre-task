variable "aws_region" {
  type = string
}

variable "aws_profile" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "subnet_cidr_block1" {
  type = string
}
variable "subnet_cidr_block2" {
  type = string
}

variable "env" {
  type = string
}

variable "avail_zone1" {
  type = string
}
variable "avail_zone2" {
  type = string
}
variable "ami_name" {
  type = string
}
variable "instance_type" {
  type = string
}

variable "private_key_file" {
  type = string

}
variable "remote_user" {
  type = string
}
