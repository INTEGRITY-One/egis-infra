## Final outputs of process

output "bastion_ip" {
      value = "${module.bastion.bastion_ip}"
    }
    
output "master_ip1" {
      value = "${module.master_cluster.instance1_ip}"
    }
output "master_ip2" {
      value = "${module.master_cluster.instance2_ip}"
    }
output "master_ip3" {
      value = "${module.master_cluster.instance3_ip}"
    }
output "master_hostname1" {
      value = "${module.master_cluster.instance1_hostname}"
    }
output "master_hostname2" {
      value = "${module.master_cluster.instance2_hostname}"
    }
output "master_hostname3" {
      value = "${module.master_cluster.instance3_hostname}"
    }

output "node_ip1" {
      value = "${module.node_cluster.instance1_ip}"
    }
output "node_ip2" {
      value = "${module.node_cluster.instance2_ip}"
    }
output "node_ip3" {
      value = "${module.node_cluster.instance3_ip}"
    }
output "node_hostname1" {
      value = "${module.node_cluster.instance1_hostname}"
    }
output "node_hostname2" {
      value = "${module.node_cluster.instance2_hostname}"
    }
output "node_hostname3" {
      value = "${module.node_cluster.instance3_hostname}"
    }
