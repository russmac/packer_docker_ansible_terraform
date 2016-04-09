///### VPC
### ECS

module "vpc" {
  source = "git::https://github.com/terraform-community-modules/tf_aws_vpc.git?ref=master"
  name = "pdat-vpc"
  cidr = "${var.vpc_cidr}"
  private_subnets = "${var.subnet_private_cidr}"
  public_subnets  = "${var.subnet_public_cidr}"
  azs      = "${lookup(var.azs-map, var.region)}"
}

resource "aws_security_group" "pdat-security-group" {
  name = "pdat-security-group"
  description = "pdat_security_group"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_groups =["${aws_security_group.pdat-elb-security-group.id}"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["${var.allow_to_80}"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "pdat-ecs-security-group"
  }
}

resource "aws_security_group" "pdat-elb-security-group" {
  name = "pdat-elb-security-group"
  description = "pdat_security_group"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${var.allow_to_80}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "pdat-elb-security-group"
  }
}




### RDS

resource "aws_security_group" "pdat-rds-security-group" {
  name = "pdat-rds-security-group"
  description = "pdat_rds_security_group"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["${element(split(",",var.subnet_public_cidr),0)}","${element(split(",",var.subnet_public_cidr),1)}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_all"
  }
}


resource "aws_subnet" "pdat-rds-a" {
  vpc_id = "${module.vpc.vpc_id}"
  cidr_block = "${var.rds_subnet_a}"
  availability_zone = "${element(split(",",lookup(var.azs-map, var.region)),0)}"
  tags {
    Name = "pdat_rds_a"
  }
}

resource "aws_subnet" "pdat-rds-b" {
  vpc_id = "${module.vpc.vpc_id}"
  cidr_block = "${var.rds_subnet_b}"
  availability_zone = "${element(split(",",lookup(var.azs-map, var.region)),1)}"
    tags {
      Name = "pdat_rds_b"
    }
}

resource "aws_db_subnet_group" "pdat-rds-subnet-group" {
  name = "pdat-rds-subnet-group"
  description = "pdat rds subnet group"
  subnet_ids = ["${aws_subnet.pdat-rds-a.id}","${aws_subnet.pdat-rds-b.id}"]
    tags {
      Name = "pdat rds subnet group"
    }
}
