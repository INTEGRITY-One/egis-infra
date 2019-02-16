output "app_ip1" {
      value = "${module.instances.instance1_ip}"
    }
output "app_ip2" {
      value = "${module.instances.instance2_ip}"
    }
output "app_ip3" {
      value = "${module.instances.instance3_ip}"
    }
output "hostname1" {
      value = "${module.instances.app1_hostname}"
    }
output "hostname2" {
      value = "${module.instances.app2_hostname}"
    }
output "hostname3" {
      value = "${module.instances.app3_hostname}"
    }
