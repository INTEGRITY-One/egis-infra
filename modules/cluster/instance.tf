#Profile to be used during the provisioning

## Define cluster instances (cluster size controlled manually by first_number and second_number)

resource "aws_instance" "instance_1" {
	
    ami = "${var.node_ami_id}"
    instance_type = "${var.instance_type}"

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
        Application = "RedHat OCP"
        ResourcePOC = "${var.resource_poc_tag}"
        Environment = "${upper("${var.environment_tag}")}"
        "kubernetes.io/cluster/openshift" = "owned"
    }
}

data "template_file" "init1" {
  template = "${file("${path.module}/files/userdata.tpl")}"
  vars {
    hostname = "${var.name_org}${var.name_application}${var.environment_tag}${var.first_number}.${var.domain_name}"
    username = "${var.redhat_username}"
    password = "${var.redhat_password}"
    pool_id = "${var.redhat_pool_id}"
  }
}

resource "aws_instance" "instance_2" {
	
    ami = "${var.node_ami_id}"
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
        Application = "RedHat OCP"
        ResourcePOC = "${var.resource_poc_tag}"
        Environment = "${upper("${var.environment_tag}")}"
        "kubernetes.io/cluster/openshift" = "owned"
    }
}

data "template_file" "init2" {
  template = "${file("${path.module}/files/userdata.tpl")}"
  vars {
    hostname = "${var.name_org}${var.name_application}${var.environment_tag}${var.second_number}.${var.domain_name}"
    username = "${var.redhat_username}"
    password = "${var.redhat_password}"
    pool_id = "${var.redhat_pool_id}"
  }
}

resource "aws_instance" "instance_3" {
	
    ami = "${var.node_ami_id}"
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
        Application = "RedHat OCP"
        ResourcePOC = "${var.resource_poc_tag}"
        Environment = "${upper("${var.environment_tag}")}"
        "kubernetes.io/cluster/openshift" = "owned"
    }
}

data "template_file" "init3" {
  template = "${file("${path.module}/files/userdata.tpl")}"
  vars {
    hostname = "${var.name_org}${var.name_application}${var.environment_tag}${var.third_number}.${var.domain_name}"
    username = "${var.redhat_username}"
    password = "${var.redhat_password}"
    pool_id = "${var.redhat_pool_id}"
  }
}

## Add new entries to the DNS Zone file
resource "aws_route53_record" "alias1" {
  zone_id = "${var.lb_hosted_zone_id}"
  name    = "${var.name_org}${var.name_application}${var.environment_tag}${var.first_number}.${var.domain_name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.instance_1.private_ip}"]
}
resource "aws_route53_record" "alias2" {
  zone_id = "${var.lb_hosted_zone_id}"
  name    = "${var.name_org}${var.name_application}${var.environment_tag}${var.second_number}.${var.domain_name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.instance_2.private_ip}"]
}
resource "aws_route53_record" "alias3" {
  zone_id = "${var.lb_hosted_zone_id}"
  name    = "${var.name_org}${var.name_application}${var.environment_tag}${var.third_number}.${var.domain_name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.instance_3.private_ip}"]
}

## Create LB Target Groups for this cluster

resource "aws_lb_target_group" "instance_http_tg" {
    name_prefix = "${var.name_application}-"
    port = "80"
    protocol = "HTTP"
    vpc_id = "${var.vpc_id}"
    stickiness {
    	type = "lb_cookie"
    	enabled = "false"
    }
}

resource "aws_lb_target_group" "instance_http2_tg" {
    name_prefix = "${var.name_application}-"
    port = "8080"
    protocol = "HTTP"
    vpc_id = "${var.vpc_id}"
    stickiness {
    	type = "lb_cookie"
    	enabled = "false"
    }
}

resource "aws_lb_target_group" "instance_https_tg" {
    name_prefix = "${var.name_application}-"
    port = "443"
    protocol = "HTTPS"
    vpc_id = "${var.vpc_id}"
    stickiness {
    	type = "lb_cookie"
    	enabled = "false"
    }
}

resource "aws_lb_target_group" "instance_https2_tg" {
    name_prefix = "${var.name_application}-"
    port = "8443"
    protocol = "HTTPS"
    vpc_id = "${var.vpc_id}"
    stickiness {
    	type = "lb_cookie"
    	enabled = "false"
    }
}

## Add new instance to LB Target

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

resource "aws_lb_target_group_attachment" "tg_http2_attachment_1" {
  target_group_arn = "${aws_lb_target_group.instance_http2_tg.arn}"
  target_id        = "${aws_instance.instance_1.id}"
  port             = "8080"
}

resource "aws_lb_target_group_attachment" "tg_http2_attachment_2" {
  target_group_arn = "${aws_lb_target_group.instance_http2_tg.arn}"
  target_id        = "${aws_instance.instance_2.id}"
  port             = "8080"
}

resource "aws_lb_target_group_attachment" "tg_http2_attachment_3" {
  target_group_arn = "${aws_lb_target_group.instance_http2_tg.arn}"
  target_id        = "${aws_instance.instance_3.id}"
  port             = "8080"
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

resource "aws_lb_target_group_attachment" "tg_https2_attachment_1" {
  target_group_arn = "${aws_lb_target_group.instance_https2_tg.arn}"
  target_id        = "${aws_instance.instance_1.id}"
  port             = "8443"
}

resource "aws_lb_target_group_attachment" "tg_https2_attachment_2" {
  target_group_arn = "${aws_lb_target_group.instance_https2_tg.arn}"
  target_id        = "${aws_instance.instance_2.id}"
  port             = "8443"
}

resource "aws_lb_target_group_attachment" "tg_https2_attachment_3" {
  target_group_arn = "${aws_lb_target_group.instance_https2_tg.arn}"
  target_id        = "${aws_instance.instance_3.id}"
  port             = "8443"
}

## Add new listeners to LB
resource "aws_lb_listener" "cluster_http_lb_listener" {
    load_balancer_arn   = "${var.cluster_lb_arn}"
    port                = "80"
    protocol            = "HTTP"
 
    default_action {
        type = "forward"
        target_group_arn = "${aws_lb_target_group.instance_http_tg.arn}"
    }
}

resource "aws_lb_listener" "cluster_http2_lb_listener" {
    load_balancer_arn   = "${var.cluster_lb_arn}"
    port                = "8080"
    protocol            = "HTTP"
 
    default_action {
        type = "forward"
        target_group_arn = "${aws_lb_target_group.instance_http2_tg.arn}"
    }
}

resource "aws_lb_listener" "cluster_https_lb_listener" {
    load_balancer_arn   = "${var.cluster_lb_arn}"
    port                = "443"
    protocol            = "HTTPS"
    ssl_policy          = "ELBSecurityPolicy-2016-08"
    certificate_arn     = "${var.cluster_lb_cert_arn}"

    default_action {
        type = "forward"
        target_group_arn = "${aws_lb_target_group.instance_https_tg.arn}"
    }
}

resource "aws_lb_listener" "cluster_https2_lb_listener" {
    load_balancer_arn   = "${var.cluster_lb_arn}"
    port                = "8443"
    protocol            = "HTTPS"
    ssl_policy          = "ELBSecurityPolicy-2016-08"
    certificate_arn     = "${var.cluster_lb_cert_arn}"
 
    default_action {
        type = "forward"
        target_group_arn = "${aws_lb_target_group.instance_https2_tg.arn}"
    }
}
