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
resource "aws_instance" "pdat-ecs-instance" {
  ami = "${var.pdat-ecs-ami}"
  instance_type = "t2.medium"
  iam_instance_profile = "${aws_iam_instance_profile.pdat-ecs-profile.id}"
  associate_public_ip_address = true
  vpc_security_group_ids = ["${aws_security_group.pdat-security-group.id}"]
  subnet_id = "${aws_subnet.pdat-public-a.id}"
  key_name = "${var.key_name}"
  user_data = "${template_file.user_data.rendered}"

  tags {
    Name = "pdat_ecs_instance"
  }

  depends_on = ["aws_iam_instance_profile.pdat-ecs-profile"]

}

resource "aws_route53_record" "pdat-ecs-route53" {
  zone_id = "${var.route53_zoneid}"
  name = "pdat.${var.route53_domain}"
  type = "A"
  ttl = "60"
  records = ["${aws_instance.pdat-ecs-instance.public_ip}"]
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
  desired_count = 1


  iam_role = "${aws_iam_role.pdat-ecs-role.id}"

  load_balancer {
    elb_name = "${aws_elb.pdat-elb.id}"
    container_name = "${var.container_name}"
    container_port = 80
  }

 depends_on = ["aws_elb.pdat-elb","aws_iam_role.pdat-ecs-role","aws_iam_role_policy.pdat-ecs-policy","aws_instance.pdat-ecs-instance"]

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
  availability_zones = [
    "us-east-1b"]

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
    target = "HTTP:80/"
    interval = 30
  }

  cross_zone_load_balancing = false
  idle_timeout = 400
  connection_draining = false

  tags {
    Name = "pdat_elb"
  }
}

output "public EIP" {
  value = "http://pdat.graphenic.com.au : ec2-user@${aws_instance.pdat-ecs-instance.public_ip}"
}

output "cluster_name" {
  value = "${var.cluster_name}"
}