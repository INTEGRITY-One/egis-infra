#Environment-specific variables

#Region for the OCP VPC
variable "aws_region" {
   default = "eu-west-2"
}

#Availability Zones (Region-dependent)
variable "aws_az1" {
   default = "eu-west-2a"
}
variable "aws_az2" {
   default = "eu-west-2b"
}
variable "aws_az3" {
   default = "eu-west-2c"
}

#Elastic IP Allocation IDs (Region-dependent)
variable "aws_eip1" {
   default = "eipalloc-077da9aee8d3ba8c1"
}
variable "aws_eip2" {
   default = "eipalloc-025cd1b7add9439d8"
}
variable "aws_eip3" {
   default = "eipalloc-0cb46c0f2e9910d42"
}

#Default AMI to use for Node instances
variable "node_ami_id" {
   default = "ami-0664a710233d7c148" # Amazon Linux
   #default = "ami-05e91c491f6eda1a3"
}

#Default AMI to use for the Bastion server
variable "bastion_ami_id" {
   default = "ami-0664a710233d7c148" # Amazon Linux
   #default = "ami-055736f71d0590f3b" # Windows 2012
}

#Point of contact for the resources
variable "resource_poc_tag" {
   default = "ed.hollingsworth@ionep.com"
}

#Identifies what the environment is, i.e. DEV, PRD, etc.
variable "environment_tag" {
   default = "dev"
}

#SSH Key used to log into instances (also Region-dependent)
variable "key_name" {
   default = "openshift-poc"
}

#Organization - used for dynamic name generation, e.g. hostname
variable "name_org" {
   default = "iop"
}

#Application name - used for dynamic name generation, e.g. hostname
variable "name_application" {
   default = "egis"
}

#Platform name - used for dynamic name generation, e.g. hostname
variable "name_platform" {
   default = "ocp"
}