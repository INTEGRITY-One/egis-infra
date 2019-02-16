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