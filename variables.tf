variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_key_path" {}
variable "aws_key_name" {}
variable "private_key_path" {}

variable "aws_region" {
    description = "EC2 Region for the VPC"
    default = "eu-west-2"
}

variable "az_1" {
    description = "EC2 Region Availability Zone 1"
    default = "eu-west-2a"
}

variable "az_2" {
    description = "EC2 Region Availability Zone 2"
    default = "eu-west-2b"
}

variable "db_ami" {
    description = "DB Instances AMI by region"
    default = {
        eu-west-2 = "ami-66051402" # ubuntu 16.04 LTS
    }
}

variable "db_arbiter_instance_type" {
    description = "DB Aarbiter Instances Type"
    default = "t2.micro"
}

variable "db_instance_type" {
    description = "DB Instances Type"
    default = "t2.large"
}

variable "web_ami" {
    description = "Web Server Instances AMI by region"
    default = {
        eu-west-2 = "ami-66051402" # ubuntu 16.04 LTS
    }
}

variable "web_instance_type" {
    description = "Web Server Instances Type"
    default = "t2.large"
}

variable "nat_ami" {
    description = "Web Server Instances AMI by region"
    default = {
        eu-west-2 = "ami-0a4c5a6e" # this is a special ami preconfigured to do NAT
    }
}

variable "nat_instance_type" {
    description = "Web Server Instances Type"
    default = "t2.small"
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}

variable "public_subnet_cidr_1" {
    description = "CIDR for the Public Subnet 1"
    default = "10.0.0.0/24"
}

variable "public_subnet_cidr_2" {
    description = "CIDR for the Public Subnet 2"
    default = "10.0.2.0/24"
}

variable "private_subnet_cidr_1" {
    description = "CIDR for the Private Subnet 1"
    default = "10.0.1.0/24"
}

variable "private_subnet_cidr_2" {
    description = "CIDR for the Private Subnet 2"
    default = "10.0.3.0/24"
}