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
  
  # Region and Availability Zones
  aws_region		= "${var.aws_region}"
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

## Define the Custom SG for the Bastion Host

resource "aws_security_group" "bastion_sg" {
    name = "${lower("${var.name_org}-${var.name_application}-${var.environment_tag}-bastion-sg")}"
    vpc_id = "${module.ocp-sdn.ocp_vpc}"

    ingress {
        from_port   = "22"
        to_port     = "22"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow SSH from external"
    }
    
    #ingress {
    #    from_port   = "3389"
    #    to_port     = "3389"
    #    protocol    = "tcp"
    #    cidr_blocks = ["0.0.0.0/0"]
    #    description = "Allow RDC from external"
    #}
    
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        name = "${lower("${var.name_org}-${var.name_application}-${var.environment_tag}-bastion-sg")}"
        Application = "RedHat OCP Bastion Host"
		ResourcePOC = "${var.resource_poc_tag}"
        Environment = "${upper("${var.environment_tag}")}"
    }
}

## Next, invoke the bastion creation module, overriding appropriate parameters

#module "bastion_win" {
#  source = "../modules/bastion"
  
#  vpc_id 			= "${module.ocp-sdn.ocp_vpc}"
#  subnet_id 		= "${module.ocp-sdn.public_subnet1}"
  
#  bastion_ami_id 	= "${var.bastion_win_ami_id}"
  
  # This SG allows the bastion to talk to the nodes
#  custom_sg 		= "${module.ocp-sdn.private_subnets_sg}"
#  bastion_sg		= "${aws_security_group.bastion_sg.id}"
  
#  name_org 			= "${var.name_org}"
#  name_application 	= "${var.name_application}"
#  name_platform 	= "${var.name_platform}"
#  key_name 			= "${var.key_name}"
#  environment_tag 	= "${var.environment_tag}"
#  resource_poc_tag 	= "${var.resource_poc_tag}"

#  instance_type 	= "t2.large"
#  OSDiskSize 		= "200"
#  DataDiskSize 		= "100"
#}

## Secondary Linux Bastion

module "bastion_linux" {
  source = "../modules/bastion"
  
  vpc_id 			= "${module.ocp-sdn.ocp_vpc}"
  subnet_id 		= "${module.ocp-sdn.public_subnet1}"
  
  bastion_ami_id 	= "${var.bastion_linux_ami_id}"
  
  # This SG allows the bastion to talk to the nodes
  bastion_sg		= "${aws_security_group.bastion_sg.id}"
  
  name_org 			= "${var.name_org}"
  name_application 	= "${var.name_application}"
  name_platform 	= "${var.name_platform}"
  key_name 			= "${var.key_name}"
  environment_tag 	= "${var.environment_tag}"
  resource_poc_tag 	= "${var.resource_poc_tag}"

  instance_type 	= "t2.micro"
  OSDiskSize 		= "50"
  DataDiskSize 		= "25"
}

## Define the Shared security group for the Master nodes
# Defined here for 3 reasons:
# 1.) Can't put it in infra module because we need the Bastion SG defined
# 2.) Can't put it in cluster module because it needs to span BOTH clusters
# 3.) Need to be able to send to to cluster module twice
#

resource "aws_security_group" "shared_sg" {
    name = "${lower("${var.name_org}-${var.name_application}-${var.environment_tag}-shared-sg")}"
    vpc_id = "${module.ocp-sdn.ocp_vpc}"

    ingress {
        from_port   = "0"
        to_port     = "65535"
        protocol    = "tcp"
        self		= "true"
        description = "Allow unrestricted internal traffic"
    }
    
    ingress {
        from_port   = "22"
        to_port     = "22"
        protocol    = "tcp"
        security_groups = ["${aws_security_group.bastion_sg.id}"]
        description = "Allow SSH from bastion"
    }
    
    ingress {
        from_port   = "8443"
        to_port     = "8443"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "External HTTPS for Admin console"
    }
    
    ingress {
        from_port   = "443"
        to_port     = "443"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "External HTTPS for all secure routes"
    }
    
    ingress {
        from_port   = "80"
        to_port     = "80"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "External HTTP for all non-secure routes"
    }
    
    ingress {
        from_port   = "8" # Echo Request (Ping)
        to_port     = "-1" # N/A
        protocol    = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow Ping from all"
    }
    
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        name = "${lower("${var.name_org}-${var.name_application}-${var.environment_tag}-shared-sg")}"
        Application = "RedHat OCP Shared SG"
		ResourcePOC = "${var.resource_poc_tag}"
        Environment = "${upper("${var.environment_tag}")}"
    }
}

## Next, invoke the instance creation module, overriding appropriate parameters

module "master_cluster" {
  source = "../modules/cluster"
  
  vpc_id 			= "${module.ocp-sdn.ocp_vpc}"
  subnet_id1 		= "${module.ocp-sdn.private_subnet1}"
  subnet_id2 		= "${module.ocp-sdn.private_subnet2}"
  subnet_id3 		= "${module.ocp-sdn.private_subnet3}"
  
  node_ami_id 		= "${var.node_ami_id}"
  
  custom_sg 		= "${aws_security_group.shared_sg.id}"
  
  name_org 			= "${var.name_org}"
  name_application 	= "${var.name_application}"
  name_platform 	= "${var.name_platform}"
  key_name 			= "${var.key_name}"
  environment_tag 	= "${var.environment_tag}"
  resource_poc_tag 	= "${var.resource_poc_tag}"

  instance_type 	= "t2.large"
  OSDiskSize 		= "100"
  DataDiskSize 		= "50"
  first_number 		= "001"
  second_number 	= "002"
  third_number 		= "003"

  cluster_lb_arn	= "${module.ocp-sdn.master_lb_arn}"
  cluster_port		= "8443"
}

## Finally, invoke the instance creation module a second time, overriding appropriate parameters

module "node_cluster" {
  source = "../modules/cluster"
  
  vpc_id 			= "${module.ocp-sdn.ocp_vpc}"
  subnet_id1 		= "${module.ocp-sdn.private_subnet1}"
  subnet_id2 		= "${module.ocp-sdn.private_subnet2}"
  subnet_id3 		= "${module.ocp-sdn.private_subnet3}"
  
  node_ami_id 		= "${var.node_ami_id}"
  
  custom_sg 		= "${aws_security_group.shared_sg.id}"
  
  name_org 			= "${var.name_org}"
  name_application 	= "${var.name_application}"
  name_platform 	= "${var.name_platform}"
  key_name 			= "${var.key_name}"
  environment_tag 	= "${var.environment_tag}"
  resource_poc_tag 	= "${var.resource_poc_tag}"

  instance_type 	= "t2.large"
  OSDiskSize 		= "100"
  DataDiskSize 		= "50"
  first_number 		= "004"
  second_number 	= "005"
  third_number 		= "006"

  cluster_lb_arn 	= "${module.ocp-sdn.node_lb_arn}"
  cluster_port		= "8080"
}