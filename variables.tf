variable "azs-map" {
  type = "map"
  default = {
    us-east-1 = "us-east-1b,us-east-1c"
    us-west-1 = "us-west-1a,us-west-1b"
    us-west-2 = "us-west-2a,us-west-2b"
  }
}

variable "region" {
  type   = "string"
  default= "us-east-1"
}

variable "vpc_cidr" {
  type   = "string"
  default= "10.0.0.0/16"
}
variable "subnet_private_cidr" {
  type   = "string"
  default= "10.0.3.0/24,10.0.4.0/24"
}
variable "subnet_public_cidr" {
  type   = "string"
  default= "10.0.1.0/24,10.0.2.0/24"
}

variable "rds_subnet_a" {
  type   = "string"
  default= "10.0.5.0/24"
}

variable "rds_subnet_b" {
  type   = "string"
  default= "10.0.6.0/24"
}

variable "cluster_name" {
  type   = "string"
  default= "pdat_ecs_cluster"
}

variable "key_name" {
  type   = "string"
  default= ""
}

variable "allow_to_80" {
  type   = "string"
  default= ""
}

variable "ecs_instance_size" {
  type = "string"
  default = "t2.small"
}

variable "ecs_task_count" {
  type   = "string"
  default= "1"
}

variable "ecs_instance_desired" {
  type   = "string"
  default= "1"
}

variable "ecs_instance_min" {
  type   = "string"
  default= "1"
}

variable "ecs_instance_max" {
  type   = "string"
  default= "1"
}

variable "pdat-ecs-ami-map" {
  type   = "map"

  default = {
    us-east-1 = "ami-67a3a90d"
    us-west-1 = "ami-b7d5a8d7"
    us-west-2 = "ami-c7a451a7"
  }

}

variable "container_name" {
  type   = "string"
  default= "pdat_wordpress"
}

variable "route53_domain" {
  type   = "string"
  default= ""
}

variable "public_hostname" {
  type   = "string"
  default= ""
}

variable "route53_zoneid" {
  type   = "string"
  default= ""
}

variable "rds_instance_size" {
  type   = "string"
  default= "db.t2.micro"
}

variable "rds_master_password" {
  type   = "string"
  default= ""
}