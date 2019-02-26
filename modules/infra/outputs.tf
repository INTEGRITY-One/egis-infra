# VPC and Subnet info
output "ocp_vpc"{
  value = "${aws_vpc.ocp_vpc.id}"
}

output "public_subnet1"{
  value = "${aws_subnet.public_subnet1.id}"
}
output "public_subnet2"{
  value = "${aws_subnet.public_subnet2.id}"
}
output "public_subnet3"{
  value = "${aws_subnet.public_subnet3.id}"
}

output "private_subnet1"{
  value = "${aws_subnet.private_subnet1.id}"
}
output "private_subnet2"{
  value = "${aws_subnet.private_subnet2.id}"
}
output "private_subnet3"{
  value = "${aws_subnet.private_subnet3.id}"
}

# Load Balancer info
output "master_lb_arn"{
  value = "${aws_lb.master_lb.arn}"
}
output "master_lb_dnsname"{
  value = "${aws_lb.master_lb.dns_name}"
}
output "node_lb_arn"{
  value = "${aws_lb.node_lb.arn}"
}
