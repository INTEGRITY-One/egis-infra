output "ocp_vpc"{
  value = "${aws_vpc.ocp_vpc.id}"
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

output "public_subnet1"{
  value = "${aws_subnet.public_subnet1.id}"
}
output "public_subnet2"{
  value = "${aws_subnet.public_subnet2.id}"
}
output "public_subnet3"{
  value = "${aws_subnet.public_subnet3.id}"
}

output "public_subnets_sg"{
  value = "${aws_security_group.public_subnets_sg.id}"
}