output "bastion_ip"{
  value = "${aws_instance.bastion.public_ip}"
}

output "bastion_hostname"{
  value = "${aws_instance.bastion.tags.Name}"
}
