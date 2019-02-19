## Final outputs of process

output "bastion_ip" {
      value = "${module.bastion.bastion_ip}"
    }

output "app_ip1" {
      value = "${module.node_cluster.instance1_ip}"
    }
output "app_ip2" {
      value = "${module.node_cluster.instance2_ip}"
    }
output "app_ip3" {
      value = "${module.node_cluster.instance3_ip}"
    }
output "hostname1" {
      value = "${module.node_cluster.instance1_hostname}"
    }
output "hostname2" {
      value = "${module.node_cluster.instance2_hostname}"
    }
output "hostname3" {
      value = "${module.node_cluster.instance3_hostname}"
    }
