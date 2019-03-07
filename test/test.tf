## Environment configuration
## see variables.tf for specific settings

terraform {
  backend "s3" {
    region 			= "us-east-2"
    profile 		= "iop-egis"        

    bucket 			= "iop-egis"
    key 			= "tfstate/tst"

    skip_credentials_validation = "true"
  }
}

## For TST, we leverage existing SDN for the OCP cluster

#module "ocp-sdn" {
#  source = "../modules/infra"
#  
  # Region and Availability Zones
#  aws_region		= "${var.aws_region}"
#  aws_az1 			= "${var.aws_az1}"
#  aws_az2 			= "${var.aws_az2}"
#  aws_az3 			= "${var.aws_az3}"
  
  # Environment-specific Elastic IP Allocation IDs
#  eipalloc_id1 		= "${var.aws_eip1}"
#  eipalloc_id2 		= "${var.aws_eip2}"
#  eipalloc_id3 		= "${var.aws_eip3}"
  
#  name_org 			= "${var.name_org}"
#  name_application 	= "${var.name_application}"
#  environment_tag 	= "${var.environment_tag}"
#  resource_poc_tag 	= "${var.resource_poc_tag}"
#}

## Instead of creating the entire SDN, we create just the LBs here:

## Define the Custom SG for the Master LB

resource "aws_security_group" "master_lb_sg" {
    name = "${lower("${var.name_org}-${var.name_application}-${var.environment_tag}-lb-sg")}"
    vpc_id = "${var.ocp_vpc}"

    ingress {
        from_port   = "80"
        to_port     = "80"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow HTTP from external"
    }
    
    ingress {
        from_port   = "8080"
        to_port     = "8080"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow secondary HTTP from external"
    }
    
    ingress {
        from_port   = "443"
        to_port     = "443"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow HTTPS from external"
    }
    
    ingress {
        from_port   = "8443"
        to_port     = "8443"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow HTTPS (admin) from external"
    }
    
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        name = "${lower("${var.name_org}-${var.name_application}-${var.environment_tag}-lb-sg")}"
        Application = "SG for Public-facing Load Balancer"
		ResourcePOC = "${var.resource_poc_tag}"
        Environment = "${upper("${var.environment_tag}")}"
        "kubernetes.io/cluster/openshift" = "owned"
    }
}

resource "aws_lb" "master_lb" {
  name               = "${lower("${var.name_org}-${var.name_application}-${var.environment_tag}-master-alb")}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.master_lb_sg.id}"]
  subnets            = ["${var.public_subnet1}",
					"${var.public_subnet2}",
					"${var.public_subnet3}"]

  # This is just so Terraform can destroy the LB without user intervention
  enable_deletion_protection = false

  tags = {
    Name = "${lower("${var.name_org}-${var.name_application}-${var.environment_tag}-master-alb")}"
    Environment = "${upper("${var.environment_tag}")}"
    "kubernetes.io/cluster/openshift" = "owned"
  }
}

resource "aws_route53_record" "master-alias" {
  zone_id = "${var.hosted_zone_id}"
  name    = "${var.name_application}-demo.${var.domain_name}"
  type    = "A"

  alias {
    name                   = "${aws_lb.master_lb.dns_name}"
    zone_id                = "${aws_lb.master_lb.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_lb" "node_lb" {
  name               = "${lower("${var.name_org}-${var.name_application}-${var.environment_tag}-node-alb")}"
  internal           = true
  load_balancer_type = "application"
  subnets            = ["${var.private_subnet1}",
					"${var.private_subnet2}",
					"${var.private_subnet3}"]

  # This is just so Terraform can destroy the LB without user intervention
  enable_deletion_protection = false

  tags = {
    Name = "${lower("${var.name_org}-${var.name_application}-${var.environment_tag}-node-alb")}"
    Environment = "${upper("${var.environment_tag}")}"
    "kubernetes.io/cluster/openshift" = "owned"
  }
}

## Define the Custom SG for the Bastion Host

resource "aws_security_group" "bastion_sg" {
    name = "${lower("${var.name_org}-${var.name_application}-${var.environment_tag}-bastion-sg")}"
    vpc_id = "${var.ocp_vpc}"

    ingress {
        from_port   = "22"
        to_port     = "22"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow SSH from external"
    }
    
    ingress {
        from_port   = "3389"
        to_port     = "3389"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow RDC from external"
    }
    
    ingress {
        from_port   = "0"
        to_port     = "65535"
        protocol    = "tcp"
        self		= "true"
        description = "Allow unrestricted internal traffic"
    }
    
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

## Primary (Windows) Bastion

module "bastion_win" {
  source                = "../modules/bastion"
  
  vpc_id                = "${var.ocp_vpc}"
  subnet_id             = "${var.public_subnet1}"
  
  bastion_ami_id        = "${var.bastion_win_ami_id}"
  
  # This SG allows the bastion to talk to the nodes
  bastion_sg            = "${aws_security_group.bastion_sg.id}"
  
  name_org              = "${var.name_org}"
  name_application      = "${var.name_application}"
  name_platform         = "${var.name_platform}"
  key_name              = "${var.key_name}"
  environment_tag       = "${var.environment_tag}"
  resource_poc_tag      = "${var.resource_poc_tag}"

  instance_type         = "t2.medium"
  OSDiskSize            = "100"
  DataDiskSize          = "50"
  bastion_number        = "010"
}

## Secondary Linux Bastion

#module "bastion_linux" {
#  source                = "../modules/bastion"
#  
#  vpc_id                = "${var.ocp_vpc}"
#  subnet_id             = "${var.public_subnet1}"
#  
#  bastion_ami_id        = "${var.bastion_linux_ami_id}"
#  
#  # This SG allows the bastion to talk to the nodes
#  bastion_sg            = "${aws_security_group.bastion_sg.id}"
#  
#  name_org              = "${var.name_org}"
#  name_application      = "${var.name_application}"
#  name_platform         = "${var.name_platform}"
#  key_name              = "${var.key_name}"
#  environment_tag       = "${var.environment_tag}"
#  resource_poc_tag      = "${var.resource_poc_tag}"
#
#  instance_type         = "t2.micro"
#  OSDiskSize            = "50"
#  DataDiskSize          = "25"
#  bastion_number        = "011"
#}

## Define the Shared security group for the Master nodes
# Defined here for 3 reasons:
# 1.) Can't put it in infra module because we need the Bastion SG defined
# 2.) Can't put it in cluster module because it needs to span BOTH clusters
# 3.) Need to be able to send to to cluster module twice
#

resource "aws_security_group" "shared_sg" {
    name = "${lower("${var.name_org}-${var.name_application}-${var.environment_tag}-shared-sg")}"
    vpc_id = "${var.ocp_vpc}"

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
        from_port   = "443"
        to_port     = "443"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "External HTTPS for all secure routes"
    }
    
    ingress {
        from_port   = "8443"
        to_port     = "8443"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "External HTTPS for Admin console"
    }
    
    ingress {
        from_port   = "80"
        to_port     = "80"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "External HTTP for all non-secure routes"
    }
    
    ingress {
        from_port   = "8080"
        to_port     = "8080"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "External HTTP for special non-secure routes"
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
        "kubernetes.io/cluster/openshift" = "owned"
    }
}

## Next, invoke the instance creation module, overriding appropriate parameters

module "master_cluster" {
  source = "../modules/cluster"
  
  vpc_id 			= "${var.ocp_vpc}"
  subnet_id1 		= "${var.private_subnet1}"
  subnet_id2 		= "${var.private_subnet2}"
  subnet_id3 		= "${var.private_subnet3}"
  
  node_ami_id 		= "${var.node_ami_id}"
  
  custom_sg 		= "${aws_security_group.shared_sg.id}"
  
  name_org 			= "${var.name_org}"
  name_application 	= "${var.name_application}"
  name_platform 	= "${var.name_platform}"
  key_name 			= "${var.key_name}"
  environment_tag 	= "${var.environment_tag}"
  resource_poc_tag 	= "${var.resource_poc_tag}"
  domain_name	    = "${var.domain_name}"

  instance_type 	= "t2.large"
  OSDiskSize 		= "100"
  DataDiskSize 		= "50"
  first_number 		= "001"
  second_number 	= "002"
  third_number 		= "003"

  cluster_lb_arn	= "${aws_lb.master_lb.arn}"
  cluster_lb_cert_arn = "${var.master_lb_cert_arn}"
  lb_dns_name		= "${aws_lb.master_lb.dns_name}"
  lb_hosted_zone_id	= "${var.hosted_zone_id}"
  lb_cluster_zone_id = "${aws_lb.master_lb.zone_id}"
  
  redhat_username 	= "${var.redhat_username}"
  redhat_password 	= "${var.redhat_password}"
  redhat_pool_id 	= "${var.redhat_pool_id}"
}

# Wildcard entry for master cluster
resource "aws_route53_record" "apps_alias" {
  zone_id = "${var.hosted_zone_id}"
  name    = "*.apps.${var.domain_name}"
  type    = "A"
  ttl     = "300"
  records = ["${module.master_cluster.instance1_ip}",
  				"${module.master_cluster.instance2_ip}",
  				"${module.master_cluster.instance3_ip}"]
}

## Finally, invoke the instance creation module a second time, overriding appropriate parameters

module "node_cluster" {
  source = "../modules/cluster"
  
  vpc_id 			= "${var.ocp_vpc}"
  subnet_id1 		= "${var.private_subnet1}"
  subnet_id2 		= "${var.private_subnet2}"
  subnet_id3 		= "${var.private_subnet3}"
  
  node_ami_id 		= "${var.node_ami_id}"
  
  custom_sg 		= "${aws_security_group.shared_sg.id}"
  
  name_org 			= "${var.name_org}"
  name_application 	= "${var.name_application}"
  name_platform 	= "${var.name_platform}"
  key_name 			= "${var.key_name}"
  environment_tag 	= "${var.environment_tag}"
  resource_poc_tag 	= "${var.resource_poc_tag}"
  domain_name	    = "${var.domain_name}"

  instance_type 	= "t2.large"
  OSDiskSize 		= "100"
  DataDiskSize 		= "50"
  first_number 		= "004"
  second_number 	= "005"
  third_number 		= "006"

  cluster_lb_arn 	= "${aws_lb.node_lb.arn}"
  lb_dns_name		= "${aws_lb.node_lb.dns_name}"
  lb_hosted_zone_id	= "${var.hosted_zone_id}"
  lb_cluster_zone_id = "${aws_lb.node_lb.zone_id}"
    
  redhat_username 	= "${var.redhat_username}"
  redhat_password 	= "${var.redhat_password}"
  redhat_pool_id 	= "${var.redhat_pool_id}"
}