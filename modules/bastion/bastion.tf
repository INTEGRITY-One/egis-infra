#Profile to be used during the provisioning

## Define Bastion instance

resource "aws_instance" "bastion" {
	
    ami = "${var.bastion_ami_id}"
    instance_type = "${var.instance_type}"
	associate_public_ip_address = "true"

    subnet_id = "${var.subnet_id}"
    key_name = "${var.key_name}"
    vpc_security_group_ids = ["${var.bastion_sg}"]

    root_block_device {
        volume_size = "${var.OSDiskSize}"
        volume_type = "gp2"
    }
    ebs_block_device {
        device_name = "/dev/xvdb"
        volume_size = "${var.DataDiskSize}"
        volume_type = "gp2"
        delete_on_termination = true
        encrypted = true
    }

    tags {
        Name        = "${var.name_org}${var.name_application}${var.environment_tag}${var.bastion_number}"
        Application = "OCP Bastion"
        ResourcePOC = "${var.resource_poc_tag}"
        Environment = "${upper("${var.environment_tag}")}"
    }
}
