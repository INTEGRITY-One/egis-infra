## Sets up the SDN for the OCP cluster

resource "aws_vpc_dhcp_options" "ocp_vpc_dhcp" {
  domain_name       = "${var.aws_region}.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_vpc" "ocp_vpc" {
  cidr_block 		= "10.0.0.0/16"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"
  
  tags = {
    Name 			= "${var.name_org}-${var.name_application}-${var.environment_tag}-vpc"
  }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = "${aws_vpc.ocp_vpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.ocp_vpc_dhcp.id}"
}

resource "aws_internet_gateway" "public_gw" {
  vpc_id 			= "${aws_vpc.ocp_vpc.id}"

  tags = {
    Name 			= "Internet Gateway for OCP VPC"
  }
}

resource "aws_subnet" "public_subnet1" {
  vpc_id     		= "${aws_vpc.ocp_vpc.id}"
  cidr_block 		= "10.0.128.0/20"
  availability_zone = "${var.aws_az1}"

  tags = {
    Name 			= "Public subnet 1"
  }
}

resource "aws_nat_gateway" "public_subnet1_gw" {
  allocation_id 	= "${var.eipalloc_id1}" 
  subnet_id     	= "${aws_subnet.public_subnet1.id}"

  tags = {
    Name 			= "NAT Gateway for Public Subnet 1"
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id     		= "${aws_vpc.ocp_vpc.id}"
  cidr_block 		= "10.0.144.0/20"
  availability_zone = "${var.aws_az2}"

  tags = {
    Name 			= "Public subnet 2"
  }
}

resource "aws_nat_gateway" "public_subnet2_gw" {
  allocation_id 	= "${var.eipalloc_id2}" 
  subnet_id     	= "${aws_subnet.public_subnet2.id}"

  tags = {
    Name 			= "NAT Gateway for Public Subnet 2"
  }
}

resource "aws_subnet" "public_subnet3" {
  vpc_id     		= "${aws_vpc.ocp_vpc.id}"
  cidr_block 		= "10.0.160.0/20"
  availability_zone = "${var.aws_az3}"

  tags = {
    Name 			= "Public subnet 3"
  }
}

resource "aws_nat_gateway" "public_subnet3_gw" {
  allocation_id 	= "${var.eipalloc_id3}" 
  subnet_id     	= "${aws_subnet.public_subnet3.id}"

  tags = {
    Name = "NAT Gateway for Public Subnet 3"
  }
}

resource "aws_route_table" "ocp_vpc_rt" {
  vpc_id = "${aws_vpc.ocp_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.public_gw.id}"
  }

  tags = {
    Name = "Route Table for OCP VPC"
  }
}

resource "aws_route_table_association" "public_subnet1_rt_assoc" {
  subnet_id      = "${aws_subnet.public_subnet1.id}"
  route_table_id = "${aws_route_table.ocp_vpc_rt.id}"
}

resource "aws_route_table_association" "public_subnet2_rt_assoc" {
  subnet_id      = "${aws_subnet.public_subnet2.id}"
  route_table_id = "${aws_route_table.ocp_vpc_rt.id}"
}

resource "aws_route_table_association" "public_subnet3_rt_assoc" {
  subnet_id      = "${aws_subnet.public_subnet3.id}"
  route_table_id = "${aws_route_table.ocp_vpc_rt.id}"
}

## Configure Private subnets

resource "aws_subnet" "private_subnet1" {
  vpc_id     			= "${aws_vpc.ocp_vpc.id}"
  cidr_block 			= "10.0.0.0/19"
  availability_zone 	= "${var.aws_az1}"

  tags = {
    Name 				= "Private subnet 1"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id     			= "${aws_vpc.ocp_vpc.id}"
  cidr_block 			= "10.0.32.0/19"
  availability_zone 	= "${var.aws_az2}"

  tags = {
    Name 				= "Private subnet 2"
  }
}

resource "aws_subnet" "private_subnet3" {
  vpc_id     			= "${aws_vpc.ocp_vpc.id}"
  cidr_block 			= "10.0.64.0/19"
  availability_zone 	= "${var.aws_az3}"

  tags = {
    Name 				= "Private subnet 3"
  }
}

resource "aws_route_table" "ocp_private1_rt" {
  vpc_id = "${aws_vpc.ocp_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.public_subnet1_gw.id}"
  }

  tags = {
    Name = "Route Table for Private subnet 1"
  }
}

resource "aws_route_table_association" "private_subnet1_rt_assoc" {
  subnet_id      = "${aws_subnet.private_subnet1.id}"
  route_table_id = "${aws_route_table.ocp_private1_rt.id}"
}

resource "aws_route_table" "ocp_private2_rt" {
  vpc_id = "${aws_vpc.ocp_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.public_subnet2_gw.id}"
  }

  tags = {
    Name = "Route Table for Private subnet 2"
  }
}

resource "aws_route_table_association" "private_subnet2_rt_assoc" {
  subnet_id      = "${aws_subnet.private_subnet2.id}"
  route_table_id = "${aws_route_table.ocp_private2_rt.id}"
}

resource "aws_route_table" "ocp_private3_rt" {
  vpc_id = "${aws_vpc.ocp_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.public_subnet3_gw.id}"
  }

  tags = {
    Name = "Route Table for Private subnet 3"
  }
}

resource "aws_route_table_association" "private_subnet3_rt_assoc" {
  subnet_id      = "${aws_subnet.private_subnet3.id}"
  route_table_id = "${aws_route_table.ocp_private3_rt.id}"
}

resource "aws_lb" "master_lb" {
  name               = "${lower("${var.name_org}-${var.name_application}-${var.environment_tag}-master-lb")}"
  internal           = false
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.public_subnet1.id}",
					"${aws_subnet.public_subnet2.id}",
					"${aws_subnet.public_subnet3.id}"]

  enable_deletion_protection = false

  tags = {
    Name = "${lower("${var.name_org}-${var.name_application}-${var.environment_tag}-master-lb")}"
    Environment = "${upper("${var.environment_tag}")}"
    "kubernetes.io/cluster/openshift" = "owned"
  }
}

resource "aws_lb" "node_lb" {
  name               = "${lower("${var.name_org}-${var.name_application}-${var.environment_tag}-node-lb")}"
  internal           = true
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.private_subnet1.id}",
					"${aws_subnet.private_subnet2.id}",
					"${aws_subnet.private_subnet3.id}"]

  enable_deletion_protection = false

  tags = {
    Name = "${lower("${var.name_org}-${var.name_application}-${var.environment_tag}-node-lb")}"
    Environment = "${upper("${var.environment_tag}")}"
    "kubernetes.io/cluster/openshift" = "owned"
  }
}