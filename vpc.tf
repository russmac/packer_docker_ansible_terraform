///### VPC
### ECS

resource "aws_vpc" "pdat-vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "pdat-igw" {
  vpc_id = "${aws_vpc.pdat-vpc.id}"

  tags {
    Name = "pdat_igw"
  }
}

resource "aws_security_group" "pdat-security-group" {
  name = "pdat-security-group"
  description = "pdat_security_group"
  vpc_id = "${aws_vpc.pdat-vpc.id}"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/22"]
  }

  ingress {
    from_port = 80
    to_port = 80
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


resource "aws_subnet" "pdat-public-a" {
  vpc_id = "${aws_vpc.pdat-vpc.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"

  tags {
    Name = "pdat_public_a"
  }
}

resource "aws_subnet" "pdat-public-b" {
  vpc_id = "${aws_vpc.pdat-vpc.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1c"

  tags {
    Name = "pdat_public_b"
  }
}

resource "aws_route_table" "pdat-public-ab-rt" {
  vpc_id = "${aws_vpc.pdat-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.pdat-igw.id}"
  }

  tags {
    Name = "pdat-public-a-rt"
  }
}

resource "aws_route_table_association" "pdat-public-a-rt-ass" {
  subnet_id = "${aws_subnet.pdat-public-a.id}"
  route_table_id = "${aws_route_table.pdat-public-ab-rt.id}"
}

resource "aws_route_table_association" "pdat-public-b-rt-ass" {
  subnet_id = "${aws_subnet.pdat-public-b.id}"
  route_table_id = "${aws_route_table.pdat-public-ab-rt.id}"
}

### RDS

resource "aws_security_group" "pdat-rds-security-group" {
  name = "pdat-rds-security-group"
  description = "pdat_rds_security_group"
  vpc_id = "${aws_vpc.pdat-vpc.id}"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/23"]
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

resource "aws_db_subnet_group" "pdat-rds-subnet-group" {
  name = "pdat-rds-subnet-group"
  description = "pdat rds subnet group"
  subnet_ids = ["${aws_subnet.pdat-rds-a.id}", "${aws_subnet.pdat-rds-b.id}"]
  tags {
    Name = "pdat rds subnet group"
  }
}


resource "aws_subnet" "pdat-rds-a" {
  vpc_id = "${aws_vpc.pdat-vpc.id}"
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1b"

  tags {
    Name = "pdat_rds_a"
  }
}

resource "aws_subnet" "pdat-rds-b" {
  vpc_id = "${aws_vpc.pdat-vpc.id}"
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1c"

  tags {
    Name = "pdat_rds_b"
  }
}