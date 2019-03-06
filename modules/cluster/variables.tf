#Profile to be used during the provisioning

#VPC where the EC2 instances will be deployed
variable "vpc_id" {}

#Subnet (AZ1) in the VPC
variable "subnet_id1" {}

#Subnet (AZ2) in the VPC
variable "subnet_id2" {}

#Subnet (AZ3) in the VPC
variable "subnet_id3" {}

#AMI to use for instances
variable "node_ami_id" {}

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

variable "cluster_lb_arn" {}
variable "cluster_port" {}
variable "domain_name" {}

#Cert to use for SSL
variable "cluster_lb_cert_arn" {
  default = "arn:aws:acm:us-east-2:766884914534:certificate/6c6dce9d-0d88-4188-a2db-b4a90138014d"
}

#LB info
variable "lb_dns_name" {}
variable "lb_hosted_zone_id" {}
variable "lb_cluster_zone_id" {}

#RedHat info
variable "redhat_username" {}
variable "redhat_password" {}
variable "redhat_pool_id" {}
