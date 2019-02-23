## Final outputs of process

#output "bastion_ip" {
#  value = "${module.bastion_win.bastion_ip}"
#}
output "bastion2_ip" {
  value = "${module.bastion_linux.bastion_ip}"
}
    
output "master1_ip" {
  value = "${module.master_cluster.instance1_ip}"
}
output "master1_dnsname" {
  value = "${module.master_cluster.instance1_dnsname}"
}
output "master1_hostname" {
  value = "${module.master_cluster.instance1_hostname}"
}
output "master2_ip" {
  value = "${module.master_cluster.instance2_ip}"
}
output "master2_dnsname" {
  value = "${module.master_cluster.instance2_dnsname}"
}
output "master2_hostname" {
  value = "${module.master_cluster.instance2_hostname}"
}
output "master3_ip" {
  value = "${module.master_cluster.instance3_ip}"
}
output "master3_dnsname" {
  value = "${module.master_cluster.instance3_dnsname}"
}
output "master3_hostname" {
  value = "${module.master_cluster.instance3_hostname}"
}

output "node1_ip" {
  value = "${module.node_cluster.instance1_ip}"
}
output "node1_dnsname" {
  value = "${module.node_cluster.instance1_dnsname}"
}
output "node1_hostname" {
  value = "${module.node_cluster.instance1_hostname}"
}
output "node2_ip" {
  value = "${module.node_cluster.instance2_ip}"
}
output "node2_dnsname" {
  value = "${module.node_cluster.instance2_dnsname}"
}
output "node2_hostname" {
  value = "${module.node_cluster.instance2_hostname}"
}
output "node3_ip" {
  value = "${module.node_cluster.instance3_ip}"
}
output "node3_dnsname" {
  value = "${module.node_cluster.instance3_dnsname}"
}
output "node3_hostname" {
  value = "${module.node_cluster.instance3_hostname}"
}
