#These variables must be passed when the module is invoked

#EIP Availability Zones (Region-dependent)
variable "aws_az1" {}
variable "aws_az2" {}
variable "aws_az3" {}

#EIP Allocation IDs (Region-dependent)
variable "eipalloc_id1" {}
variable "eipalloc_id2" {}
variable "eipalloc_id3" {}

#Point of contact for the resources
variable "resource_poc_tag" {}

#Identifies what the environment is, i.e. DEV, PRD, etc.
variable "environment_tag" {}

#Organization - used for dynamic name generation, e.g. hostname
variable "name_org" {}

#Application name - used for dynamic name generation, e.g. hostname
variable "name_application" {}