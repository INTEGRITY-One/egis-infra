## Environment configuration
## see variables.tf for specific settings

terraform {
  backend "s3" {
    region 			= "us-east-2"
    profile 		= "iop-egis"        

    bucket 			= "iop-egis"
    key 			= "tfstate/dev"

    skip_credentials_validation = "true"
  }
}

## First, set up the SDN for the OCP cluster

module "ocp-sdn" {
  source = "../modules/infra"
  
  # Availability Zones (region-dependent)
  aws_az1 			= "${var.aws_az1}"
  aws_az2 			= "${var.aws_az2}"
  aws_az3 			= "${var.aws_az3}"
  
  # Environment-specific Elastic IP Allocation IDs
  eipalloc_id1 		= "${var.aws_eip1}"
  eipalloc_id2 		= "${var.aws_eip2}"
  eipalloc_id3 		= "${var.aws_eip3}"
  
  name_org 			= "${var.name_org}"
  name_application 	= "${var.name_application}"
  environment_tag 	= "${var.environment_tag}"
  resource_poc_tag 	= "${var.resource_poc_tag}"
}

## Next, invoke the bastion creation module, overriding appropriate parameters

module "bastion" {
  source = "../modules/bastion"
  
  vpc_id 			= "${module.ocp-sdn.ocp_vpc}"
  subnet_id 		= "${module.ocp-sdn.public_subnet1}"
  
  bastion_ami_id 	= "${var.bastion_ami_id}"
  
  custom_sg 		= "${module.ocp-sdn.public_subnets_sg}"
  
  name_org 			= "${var.name_org}"
  name_application 	= "${var.name_application}"
  name_platform 	= "${var.name_platform}"
  key_name 			= "${var.key_name}"
  environment_tag 	= "${var.environment_tag}"
  resource_poc_tag 	= "${var.resource_poc_tag}"

  instance_type 	= "t2.medium"
  OSDiskSize 		= "100"
  DataDiskSize 		= "50"
}

## Next, invoke the instance creation module, overriding appropriate parameters

module "node_cluster" {
  source = "../modules/cluster"
  
  vpc_id 			= "${module.ocp-sdn.ocp_vpc}"
  subnet_id1 		= "${module.ocp-sdn.private_subnet1}"
  subnet_id2 		= "${module.ocp-sdn.private_subnet2}"
  subnet_id3 		= "${module.ocp-sdn.private_subnet3}"
  
  node_ami_id 		= "${var.node_ami_id}"
  
  custom_sg 		= "${module.ocp-sdn.private_subnets_sg}"
  
  name_org 			= "${var.name_org}"
  name_application 	= "${var.name_application}"
  name_platform 	= "${var.name_platform}"
  key_name 			= "${var.key_name}"
  environment_tag 	= "${var.environment_tag}"
  resource_poc_tag 	= "${var.resource_poc_tag}"

  instance_type 	= "t2.medium"
  OSDiskSize 		= "100"
  DataDiskSize 		= "50"
  first_number 		= "001"
  second_number 	= "002"
  third_number 		= "003"

  #app_lb_arn = "arn:aws-us-gov:elasticloadbalancing:us-gov-west-1:257972749288:loadbalancer/net/leiss-rpx-dv/878a5f71f51b3c0f"
}