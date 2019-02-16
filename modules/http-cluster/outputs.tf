output "instance1_ip"{
  value = "${aws_instance.app_1.private_ip}"
}
output "instance2_ip"{
  value = "${aws_instance.app_2.private_ip}"
}
output "instance3_ip"{
  value = "${aws_instance.app_3.private_ip}"
}

output "app1_hostname"{
  value = "${aws_instance.app_1.tags.Name}"
}
output "app2_hostname"{
  value = "${aws_instance.app_2.tags.Name}"
}
output "app3_hostname"{
  value = "${aws_instance.app_3.tags.Name}"
}