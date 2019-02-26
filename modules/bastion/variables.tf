#Profile to be used during the provisioning

#VPC where the EC2 instances will be deployed
variable "vpc_id" {}

#Subnet in the VPC where the bastion will go
variable "subnet_id" {}

#AMI to use for the bastion server
variable "bastion_ami_id" {}

#DEFAULT EC2 instance type
variable "instance_type" {
  default = "t2.medium"
}

#DEFAULT OS Disk Size
variable "OSDiskSize" {
  default = "100"
}

#DEFAULT Data Disk Size
variable "DataDiskSize" {
  default = "50"
}

#Bastion SG
variable "bastion_sg" {}

#Point of contact for the resources
variable "resource_poc_tag" {}

#Identifies what the environment is, i.e. DEV, PRD, etc.
variable "environment_tag" {}

#key
variable "key_name" {}

variable "name_org" {}
variable "name_application" {}
variable "name_platform" {}

#variable "app_lb_arn" {}
