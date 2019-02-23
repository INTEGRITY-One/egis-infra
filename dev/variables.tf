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
   default = "ami-06292dcdd6a62ae68" # Custom CentOS (in EU-West-2)
   #default = "ami-0eab3a90fc693af19" # CentOS baseline (in EU-West-2)
}

#Default AMI to use for the Windows Bastion server
variable "bastion_win_ami_id" {
   default = "ami-00a7e816fdedd2de2" # Custom Win2k19 AMI (in EU-West-2)
}

#Default AMI to use for the Linux Bastion server
variable "bastion_linux_ami_id" {
   default = "ami-012b3fbe045483d63" # Custom Amazon Linux (in EU-West-2)
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