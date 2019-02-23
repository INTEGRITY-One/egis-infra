output "instance1_ip"{
  value = "${aws_instance.instance_1.private_ip}"
}
output "instance2_ip"{
  value = "${aws_instance.instance_2.private_ip}"
}
output "instance3_ip"{
  value = "${aws_instance.instance_3.private_ip}"
}

output "instance1_dnsname"{
  value = "${aws_instance.instance_1.private_dns}"
}
output "instance2_dnsname"{
  value = "${aws_instance.instance_2.private_dns}"
}
output "instance3_dnsname"{
  value = "${aws_instance.instance_3.private_dns}"
}

output "instance1_hostname"{
  value = "${aws_instance.instance_1.tags.Name}"
}
output "instance2_hostname"{
  value = "${aws_instance.instance_2.tags.Name}"
}
output "instance3_hostname"{
  value = "${aws_instance.instance_3.tags.Name}"
}