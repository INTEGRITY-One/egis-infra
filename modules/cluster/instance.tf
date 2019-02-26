#Profile to be used during the provisioning

## Define cluster instances (cluster size controlled manually by first_number and second_number)

resource "aws_instance" "instance_1" {
	
    ami = "${var.node_ami_id}"
    instance_type = "${var.instance_type}"

    subnet_id = "${var.subnet_id1}"
    key_name = "${var.key_name}"
    vpc_security_group_ids = ["${var.custom_sg}"]

    #user_data = "${data.template_file.init1.rendered}" 

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
        Name        = "${var.name_org}${var.name_application}${var.environment_tag}${var.first_number}"
        Application = "RedHat OCP"
        ResourcePOC = "${var.resource_poc_tag}"
        Environment = "${upper("${var.environment_tag}")}"
    }
}

#data "template_file" "init1" {
#  template = <<-EOF
#              #!/bin/bash
#              hostnamectl set-hostname "$${hostname}"
#              EOF
#
#  vars {
#    hostname = "${var.name_org}${var.name_application}${var.environment_tag}${var.first_number}.ioneplabs.com"
#  }
#}

resource "aws_instance" "instance_2" {
	
    ami = "${var.node_ami_id}"
    instance_type = "${var.instance_type}"

    subnet_id = "${var.subnet_id2}"
    key_name = "${var.key_name}"
    vpc_security_group_ids = ["${var.custom_sg}"]

    #user_data = "${data.template_file.init2.rendered}" 

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
        Name        = "${var.name_org}${var.name_application}${var.environment_tag}${var.second_number}"
        Application = "RedHat OCP"
        ResourcePOC = "${var.resource_poc_tag}"
        Environment = "${upper("${var.environment_tag}")}"
    }
}

#data "template_file" "init2" {
#  template = <<-EOF
#              #!/bin/bash
#              hostnamectl set-hostname "$${hostname}"
#              EOF
#
#  vars {
#    hostname = "${var.name_org}${var.name_application}${var.environment_tag}${var.second_number}.ioneplabs.com"
#  }
#}

resource "aws_instance" "instance_3" {
	
    ami = "${var.node_ami_id}"
    instance_type = "${var.instance_type}"

    subnet_id = "${var.subnet_id3}"
    key_name = "${var.key_name}"
    vpc_security_group_ids = ["${var.custom_sg}"]

    #user_data = "${data.template_file.init3.rendered}" 

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
        Name        = "${var.name_org}${var.name_application}${var.environment_tag}${var.third_number}"
        Application = "RedHat OCP"
        ResourcePOC = "${var.resource_poc_tag}"
        Environment = "${upper("${var.environment_tag}")}"
    }
}

#data "template_file" "init3" {
#  template = <<-EOF
#              #!/bin/bash
#              hostnamectl set-hostname "$${hostname}"
#              EOF
#
#  vars {
#    hostname = "${var.name_org}${var.name_application}${var.environment_tag}${var.third_number}.ioneplabs.com"
#  }
#}

## Create Custom LB Target Group for this cluster
resource "aws_lb_target_group" "instance_custom_tg" {
    name_prefix = "${var.name_application}-"
    port = "${var.cluster_port}"
    protocol = "TCP"
    vpc_id = "${var.vpc_id}"
    stickiness {
    	type = "lb_cookie"
    	enabled = "false"
    }
}

# Standard HTTP/HTTPS target groups
resource "aws_lb_target_group" "instance_http_tg" {
    name_prefix = "${var.name_application}-"
    port = "80"
    protocol = "TCP"
    vpc_id = "${var.vpc_id}"
    stickiness {
    	type = "lb_cookie"
    	enabled = "false"
    }
}

resource "aws_lb_target_group" "instance_https_tg" {
    name_prefix = "${var.name_application}-"
    port = "443"
    protocol = "TCP"
    vpc_id = "${var.vpc_id}"
    stickiness {
    	type = "lb_cookie"
    	enabled = "false"
    }
}

## Add new instance to LB Target
resource "aws_lb_target_group_attachment" "tg_custom_attachment_1" {
  target_group_arn = "${aws_lb_target_group.instance_custom_tg.arn}"
  target_id        = "${aws_instance.instance_1.id}"
  port             = "${var.cluster_port}"
}

resource "aws_lb_target_group_attachment" "tg_custom_attachment_2" {
  target_group_arn = "${aws_lb_target_group.instance_custom_tg.arn}"
  target_id        = "${aws_instance.instance_2.id}"
  port             = "${var.cluster_port}"
}

resource "aws_lb_target_group_attachment" "tg_custom_attachment_3" {
  target_group_arn = "${aws_lb_target_group.instance_custom_tg.arn}"
  target_id        = "${aws_instance.instance_3.id}"
  port             = "${var.cluster_port}"
}

resource "aws_lb_target_group_attachment" "tg_http_attachment_1" {
  target_group_arn = "${aws_lb_target_group.instance_http_tg.arn}"
  target_id        = "${aws_instance.instance_1.id}"
  port             = "80"
}

resource "aws_lb_target_group_attachment" "tg_http_attachment_2" {
  target_group_arn = "${aws_lb_target_group.instance_http_tg.arn}"
  target_id        = "${aws_instance.instance_2.id}"
  port             = "80"
}

resource "aws_lb_target_group_attachment" "tg_http_attachment_3" {
  target_group_arn = "${aws_lb_target_group.instance_http_tg.arn}"
  target_id        = "${aws_instance.instance_3.id}"
  port             = "80"
}

resource "aws_lb_target_group_attachment" "tg_https_attachment_1" {
  target_group_arn = "${aws_lb_target_group.instance_https_tg.arn}"
  target_id        = "${aws_instance.instance_1.id}"
  port             = "443"
}

resource "aws_lb_target_group_attachment" "tg_https_attachment_2" {
  target_group_arn = "${aws_lb_target_group.instance_https_tg.arn}"
  target_id        = "${aws_instance.instance_2.id}"
  port             = "443"
}

resource "aws_lb_target_group_attachment" "tg_https_attachment_3" {
  target_group_arn = "${aws_lb_target_group.instance_https_tg.arn}"
  target_id        = "${aws_instance.instance_3.id}"
  port             = "443"
}

## Add new listeners to LB
resource "aws_lb_listener" "cluster_custom_lb_listener" {
    load_balancer_arn = "${var.cluster_lb_arn}"
    port = "${var.cluster_port}"
    protocol = "TCP"
 
    default_action {
        target_group_arn = "${aws_lb_target_group.instance_custom_tg.arn}"
        type = "forward"
    }
}

resource "aws_lb_listener" "cluster_http_lb_listener" {
    load_balancer_arn = "${var.cluster_lb_arn}"
    port = "80"
    protocol = "TCP"
 
    default_action {
        target_group_arn = "${aws_lb_target_group.instance_http_tg.arn}"
        type = "forward"
    }
}

resource "aws_lb_listener" "cluster_https_lb_listener" {
    load_balancer_arn = "${var.cluster_lb_arn}"
    port = "443"
    protocol = "TCP"
 
    default_action {
        target_group_arn = "${aws_lb_target_group.instance_https_tg.arn}"
        type = "forward"
    }
}
