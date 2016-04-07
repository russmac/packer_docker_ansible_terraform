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

variable "region" {
  type   = "string"
  default= "us-east-1"
}

variable "pdat-ecs-ami" {
  type   = "string"
  default= "ami-43043329"
}

variable "container_name" {
  type   = "string"
  default= "pdat_wordpress"
}

variable "route53_domain" {
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