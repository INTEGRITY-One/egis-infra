#Profile to be used during the provisioning

#VPC where the EC2 instance will be deployed
variable "vpc_id" {}

#Subnet (AZ1) in the VPC
variable "subnet_id1" {}

#Subnet (AZ2) in the VPC
variable "subnet_id2" {}

#Subnet (AZ3) in the VPC
variable "subnet_id3" {}

#Default AMI to use for instances
variable "ami_id" {
  default = "ami-0664a710233d7c148" # Amazon Linux
  #default = "ami-05e91c491f6eda1a3"
}

#hostname number incrementer
variable "first_number" {
  default = "001"
}

#hostname number incrementer
variable "second_number" {
  default = "001"
}

#hostname number incrementer
variable "third_number" {
  default = "001"
}

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

#Custom SG
variable "custom_sg" {}

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
