#Profile to be used during the provisioning

## Define cluster instances (cluster size controlled manually by first_number and second_number)

resource "aws_instance" "app_1" {
	
    ami = "${var.ami_id}"
    instance_type = "${var.instance_type}"
	# Only allow public access on 1
	associate_public_ip_address = "true"

    subnet_id = "${var.subnet_id1}"
    key_name = "${var.key_name}"
    vpc_security_group_ids = ["${var.custom_sg}"]

    user_data = "${data.template_file.init1.rendered}" 

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
        Application = "RedHat OCD"
        ResourcePOC = "${var.resource_poc_tag}"
        Environment = "${upper("${var.environment_tag}")}"
    }
}

data "template_file" "init1" {
  template = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname "$${hostname}"
              EOF

  vars {
    hostname = "${var.name_org}${var.name_application}${var.environment_tag}${var.first_number}.ioneplabs.com"
  }
}

resource "aws_instance" "app_2" {
	
    ami = "${var.ami_id}"
    instance_type = "${var.instance_type}"

    subnet_id = "${var.subnet_id2}"
    key_name = "${var.key_name}"
    vpc_security_group_ids = ["${var.custom_sg}"]

    user_data = "${data.template_file.init2.rendered}" 

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
        Application = "RedHat OCD"
        ResourcePOC = "${var.resource_poc_tag}"
        Environment = "${upper("${var.environment_tag}")}"
    }
}

data "template_file" "init2" {
  template = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname "$${hostname}"
              EOF

  vars {
    hostname = "${var.name_org}${var.name_application}${var.environment_tag}${var.second_number}.ioneplabs.com"
  }
}

resource "aws_instance" "app_3" {
	
    ami = "${var.ami_id}"
    instance_type = "${var.instance_type}"

    subnet_id = "${var.subnet_id3}"
    key_name = "${var.key_name}"
    vpc_security_group_ids = ["${var.custom_sg}"]

    user_data = "${data.template_file.init3.rendered}" 

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
        Application = "RedHat OCD"
        ResourcePOC = "${var.resource_poc_tag}"
        Environment = "${upper("${var.environment_tag}")}"
    }
}

data "template_file" "init3" {
  template = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname "$${hostname}"
              EOF

  vars {
    hostname = "${var.name_org}${var.name_application}${var.environment_tag}${var.third_number}.ioneplabs.com"
  }
}

## Create ALB Target Group for this cluster
resource "aws_lb_target_group" "app_tg" {
    name = "${lower("leiss-${var.name_platform}-${var.environment_tag}")}"
    port = 8080
    protocol = "HTTP"
    vpc_id = "${var.vpc_id}"
}

## Add new instance to ALB Target
resource "aws_lb_target_group_attachment" "app_tg_attachment_1" {
  target_group_arn = "${aws_lb_target_group.app_tg.arn}"
  target_id        = "${aws_instance.app_1.id}"
  port             = 8080
}

resource "aws_lb_target_group_attachment" "app_tg_attachment_2" {
  target_group_arn = "${aws_lb_target_group.app_tg.arn}"
  target_id        = "${aws_instance.app_2.id}"
  port             = 8080
}

resource "aws_lb_target_group_attachment" "app_tg_attachment_3" {
  target_group_arn = "${aws_lb_target_group.app_tg.arn}"
  target_id        = "${aws_instance.app_3.id}"
  port             = 8080
}

## Add new listener to ALB
#resource "aws_lb_listener" "app_lb_listener" {
#    load_balancer_arn = "${var.app_lb_arn}"
#    port = "8080"
#    protocol = "HTTP"
# 
#    default_action {
#        target_group_arn = "${aws_lb_target_group.app_tg.arn}"
#        type = "forward"
#    }
#}
