//### ECS

provider "aws" {
  region = "${var.region}"
}

// Create cluster
resource "aws_ecs_cluster" "pdat-ecs-cluster" {
  name = "${var.cluster_name}"
}

resource "template_file" "user_data" {
  template = "${file("user_data.tpl")}"

  vars {
    cluster_name = "${var.cluster_name}"
  }

}

// Create instance
resource "aws_launch_configuration" "pdat-ecs-lc" {
  name = "pdat-ecs-lc"
  image_id = "${lookup(var.pdat-ecs-ami-map, var.region)}"
  instance_type = "${var.ecs_instance_size}"
  iam_instance_profile = "${aws_iam_instance_profile.pdat-ec2-profile.id}"
  key_name = "${var.key_name}"
  user_data = "${template_file.user_data.rendered}"
  depends_on = ["aws_iam_instance_profile.pdat-ec2-profile"]
}

resource "aws_autoscaling_group" "pdat-asg" {
  availability_zones = ["${element(split(",",lookup(var.azs-map, var.region)),0)}",
                        "${element(split(",",lookup(var.azs-map, var.region)),1)}"]
  name = "pdat-asg"
  max_size = "${var.ecs_instance_max}"
  min_size = "${var.ecs_instance_min}"
  health_check_grace_period = 3600
  health_check_type = "EC2"
  desired_capacity = "${var.ecs_instance_desired}"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.pdat-ecs-lc.id}"
  load_balancers=["${aws_elb.pdat-elb.id}"]
  vpc_zone_identifier=["${element(split(",",module.vpc.public_subnets),0)}",
                       "${element(split(",",module.vpc.public_subnets),1)}"]


  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_route53_record" "pdat-ecs-route53" {
  zone_id = "${var.route53_zoneid}"
  name = "pdat.${var.route53_domain}"
  type = "CNAME"
  ttl = "60"
  records = ["${aws_elb.pdat-elb.dns_name}"]
}

// Create dockerfile? ;)
resource "aws_ecs_task_definition" "pdat-ecs-wordpress" {
  family = "pdat"
  container_definitions = "${file("task-definitions/dockerfile.json")}"

  volume {
    name = "wordpress_data"
    host_path = "/srv/wordpress_data"
  }

}

// Create service
resource "aws_ecs_service" "pdat-ecs-service" {
  name = "pdat_ecs"
  cluster = "${aws_ecs_cluster.pdat-ecs-cluster.id}"
  task_definition = "${aws_ecs_task_definition.pdat-ecs-wordpress.arn}"
  desired_count = "${var.ecs_task_count}"
  iam_role = "${aws_iam_role.pdat-ecs-role.id}"

  load_balancer {
    elb_name = "${aws_elb.pdat-elb.id}"
    container_name = "${var.container_name}"
    container_port = 8080
  }

 depends_on = ["aws_elb.pdat-elb",
               "aws_iam_role.pdat-ecs-role",
               "aws_iam_role_policy.pdat-ecs-policy",
               "aws_launch_configuration.pdat-ecs-lc"]

}


//// Create ELB
resource "aws_s3_bucket" "pdat-elb-s3" {
  bucket = "pdat-elb-logs"
  acl = "private"

  tags {
    Name = "pdat-elb-s3"
  }
}

resource "aws_elb" "pdat-elb" {
  name = "pdat-elb"
  subnets = ["${element(split(",",module.vpc.public_subnets),0)}",
             "${element(split(",",module.vpc.public_subnets),1)}"]
  security_groups = ["${aws_security_group.pdat-elb-security-group.id}"]

  access_logs {
    bucket = "elb-logs"
    bucket_prefix = "pdat_"
    interval = 60
  }

  listener {
    instance_port = 8080
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "TCP:8080"
    interval = 30
  }

  cross_zone_load_balancing = true
  idle_timeout = 30

  tags {
    Name = "pdat_elb"
  }
}

output "elb" {
  value = "ELB: http://${var.public_hostname}"
}

output "cluster_name" {
  value = "${var.cluster_name}"
}