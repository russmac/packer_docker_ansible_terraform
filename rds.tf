///### RDS

resource "aws_db_instance" "pdat-rds" {
  identifier = "pdat-rds"
  allocated_storage = 10
  engine = "mysql"
  instance_class = "${var.rds_instance_size}"
  name = "pdat"
  username = "root"
  password = "${var.rds_master_password}"
  vpc_security_group_ids = ["${aws_security_group.pdat-rds-security-group.id}"]
  db_subnet_group_name = "${aws_db_subnet_group.pdat-rds-subnet-group.id}"
}

// Ansible post provisions in container and expects this CNAME to work
resource "aws_route53_record" "pdat-rds-route53" {
  zone_id = "${var.route53_zoneid}"
  name = "pdat-rds.${var.route53_domain}"
  type = "CNAME"
  ttl = "60"
  records = ["${aws_db_instance.pdat-rds.address}"]
}