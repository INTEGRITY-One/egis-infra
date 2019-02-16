## Sets up the SDN for the OCP cluster

resource "aws_vpc" "ocp_vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "${var.name_org}-${var.name_application}-${var.environment_tag}-vpc"
  }
}

resource "aws_internet_gateway" "public_gw" {
  vpc_id = "${aws_vpc.ocp_vpc.id}"

  tags = {
    Name = "Internet Gateway for OCP VPC"
  }
}

resource "aws_subnet" "public_subnet1" {
  vpc_id     = "${aws_vpc.ocp_vpc.id}"
  cidr_block = "10.0.128.0/20"
  availability_zone = "${var.aws_az1}"

  tags = {
    Name = "Public subnet 1"
  }
}

resource "aws_nat_gateway" "public_subnet1_gw" {
  allocation_id = "${var.eipalloc_id1}" 
  subnet_id     = "${aws_subnet.public_subnet1.id}"

  tags = {
    Name = "NAT Gateway for Public Subnet 1"
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id     = "${aws_vpc.ocp_vpc.id}"
  cidr_block = "10.0.144.0/20"
  availability_zone = "${var.aws_az2}"

  tags = {
    Name = "Public subnet 2"
  }
}

resource "aws_nat_gateway" "public_subnet2_gw" {
  allocation_id = "${var.eipalloc_id2}" 
  subnet_id     = "${aws_subnet.public_subnet2.id}"

  tags = {
    Name = "NAT Gateway for Public Subnet 2"
  }
}

resource "aws_subnet" "public_subnet3" {
  vpc_id     = "${aws_vpc.ocp_vpc.id}"
  cidr_block = "10.0.160.0/20"
  availability_zone = "${var.aws_az3}"

  tags = {
    Name = "Public subnet 3"
  }
}

resource "aws_nat_gateway" "public_subnet3_gw" {
  allocation_id = "${var.eipalloc_id3}" 
  subnet_id     = "${aws_subnet.public_subnet3.id}"

  tags = {
    Name = "NAT Gateway for Public Subnet 3"
  }
}

## Define the environment-specific security group

resource "aws_security_group" "public_subnets_sg" {
    name = "${lower("${var.name_org}-${var.name_application}-${var.environment_tag}-sg")}"
    vpc_id = "${aws_vpc.ocp_vpc.id}"

    ingress {
        from_port   = "22"
        to_port     = "22"
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/8"]
        description = "Allow SSH from all"
    }
    
    ingress {
        from_port   = "8080"
        to_port     = "8080"
        protocol    = "tcp"
        cidr_blocks = ["${aws_subnet.public_subnet1.cidr_block}",
					"${aws_subnet.public_subnet2.cidr_block}",
					"${aws_subnet.public_subnet3.cidr_block}"]
    }

    ingress {
        from_port   = "8443"
        to_port     = "8443"
        protocol    = "tcp"
        cidr_blocks = ["${aws_subnet.public_subnet1.cidr_block}",
					"${aws_subnet.public_subnet2.cidr_block}",
					"${aws_subnet.public_subnet3.cidr_block}"]
    }
    
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        name = "${lower("${var.name_org}-${var.name_application}-${var.environment_tag}-sg")}"
        Application = "RedHat OCP"
		ResourcePOC = "${var.resource_poc_tag}"
        Environment = "${upper("${var.environment_tag}")}"
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
  vpc_id     = "${aws_vpc.ocp_vpc.id}"
  cidr_block = "10.0.0.0/19"
  availability_zone = "${var.aws_az1}"

  tags = {
    Name = "Private subnet 1"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id     = "${aws_vpc.ocp_vpc.id}"
  cidr_block = "10.0.32.0/19"
  availability_zone = "${var.aws_az2}"

  tags = {
    Name = "Private subnet 2"
  }
}

resource "aws_subnet" "private_subnet3" {
  vpc_id     = "${aws_vpc.ocp_vpc.id}"
  cidr_block = "10.0.64.0/19"
  availability_zone = "${var.aws_az3}"

  tags = {
    Name = "Private subnet 3"
  }
}

resource "aws_security_group" "private_subnets_sg" {
  vpc_id = "${aws_vpc.ocp_vpc.id}"

  ingress {
    cidr_blocks = ["${aws_subnet.private_subnet1.cidr_block}",
					"${aws_subnet.private_subnet2.cidr_block}",
					"${aws_subnet.private_subnet3.cidr_block}"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
}