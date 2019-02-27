# VPC and Subnet info
variable "ocp_vpc"{
  default = "vpc-00f6959500333fdc9"
}

variable "public_subnet1"{
  default = "subnet-0aea7c173beede085"
}
variable "public_subnet2"{
  default = "subnet-05f358c00841e0a69"
}
variable "public_subnet3"{
  default = "subnet-07b0656f7901dc340"
}

variable "private_subnet1"{
  default = "subnet-0680964eb6f30110e"
}
variable "private_subnet2"{
  default = "subnet-04c52adba10c35006"
}
variable "private_subnet3"{
  default = "subnet-01908654c4a064790"
}

#Environment-specific variables

#Region for the OCP VPC
variable "aws_region" {
   default = "us-east-2"
}

#Availability Zones (Region-dependent)
variable "aws_az1" {
   default = "us-east-2a"
}
variable "aws_az2" {
   default = "us-east-2b"
}
variable "aws_az3" {
   default = "us-east-2c"
}

#Elastic IP Allocation IDs (Region-dependent)
variable "aws_eip1" {
   default = "eipalloc-0dfda0bc8f4b5e00d"
}
variable "aws_eip2" {
   default = "eipalloc-0a873d3e333b8ae7f"
}
variable "aws_eip3" {
   default = "eipalloc-0d33c2547e202eece"
}

#Default AMI to use for Node instances
variable "node_ami_id" {
   #default = "ami-0b500ef59d8335eee" # RHEL 7.6 baseline (in US-East-2)
   default = "ami-0ec827f0337bb4999" # Custom RHEL 7.6 [pre-Prereqs]
}

#Default AMI to use for the Windows Bastion server
variable "bastion_win_ami_id" {
   default = "ami-0eb1e0a0c9f3f85c7" # Win2k19 baseline (in US-East-2)
}

#Default AMI to use for the Linux Bastion server
variable "bastion_linux_ami_id" {
   #default = "ami-0ed72083dbed1d548" # Amazon Linux baseline (in US-East-2)
   default = "ami-02bf9d63d9e4049b6" # Custom Amazon Linux bastion (in US-East-2)
}

#Point of contact for the resources
variable "resource_poc_tag" {
   default = "ed.hollingsworth@ionep.com"
}

#Identifies what the environment is, i.e. DEV, PRD, etc.
variable "environment_tag" {
   default = "tst"
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