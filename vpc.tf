resource "aws_vpc" "default" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags {
        Name = "VFQ VPC"
    }
}

resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.default.id}"

    tags {
        Name = "VFQ IGW"
    }
}

/*
  NAT Instance
*/
resource "aws_security_group" "nat" {
    name = "vpc_nat"
    description = "Allow traffic to pass from the private subnet to the internet"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr_1}"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr_1}"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr_2}"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr_2}"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    egress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.default.id}"

    tags {
        Name = "VFQ NATSG"
    }
}

resource "aws_instance" "nat" {
    ami = "${lookup(var.nat_ami, var.aws_region)}"
    availability_zone = "${var.az_1}"
    instance_type = "${var.nat_instance_type}"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.nat.id}"]
    subnet_id = "${aws_subnet.VFQ-public-1.id}"
    associate_public_ip_address = true
    source_dest_check = false

    tags {
        Name = "VFQ VPC NAT"
    }

    # Destroy ec2 only if created successful
    lifecycle {
        create_before_destroy = true
    }

    provisioner "file" {
        source      = "${var.private_key_path}"
        destination = "~/.ssh/vfq_id_rsa.private"
        connection { 
            user = "ec2-user" 
            private_key = "${ file("${var.private_key_path}")}"
        }
    }

    provisioner "remote-exec" {
        inline = [
            "chmod 600 ~/.ssh/vfq_id_rsa.private",
            ]
        }
        connection { 
            user = "ec2-user" 
            private_key = "${ file("${var.private_key_path}")}"
        }
}

resource "aws_eip" "nat" {
    instance = "${aws_instance.nat.id}"
    vpc = true
}

/*
  Public Subnet 1
*/
resource "aws_subnet" "VFQ-public-1" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.public_subnet_cidr_1}"
    availability_zone = "${var.az_1}"

    tags {
        Name = "VFQ Public Subnet 1"
    }
}

resource "aws_route_table" "VFQ-public-1" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }

    tags {
        Name = "VFQ Public Subnet 1"
    }
}

resource "aws_route_table_association" "VFQ-public-1" {
    subnet_id = "${aws_subnet.VFQ-public-1.id}"
    route_table_id = "${aws_route_table.VFQ-public-1.id}"
}

/*
  Public Subnet 2
*/
resource "aws_subnet" "VFQ-public-2" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.public_subnet_cidr_2}"
    availability_zone = "${var.az_2}"

    tags {
        Name = "VFQ Public Subnet 2"
    }
}

resource "aws_route_table" "VFQ-public-2" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }

    tags {
        Name = "VFQ Public Subnet 2"
    }
}

resource "aws_route_table_association" "VFQ-public-2" {
    subnet_id = "${aws_subnet.VFQ-public-2.id}"
    route_table_id = "${aws_route_table.VFQ-public-2.id}"
}

/*
  Private Subnet 1
*/
resource "aws_subnet" "VFQ-private-1" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.private_subnet_cidr_1}"
    availability_zone = "${var.az_1}"

    tags {
        Name = "VFQ Private Subnet"
    }
}

resource "aws_route_table" "VFQ-private-1" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${aws_instance.nat.id}"
    }

    tags {
        Name = "VFQ Private Subnet"
    }
}

resource "aws_route_table_association" "VFQ-private-1" {
    subnet_id = "${aws_subnet.VFQ-private-1.id}"
    route_table_id = "${aws_route_table.VFQ-private-1.id}"
}

/*
  Private Subnet 2
*/
resource "aws_subnet" "VFQ-private-2" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.private_subnet_cidr_2}"
    availability_zone = "${var.az_2}"

    tags {
        Name = "VFQ Private Subnet 2"
    }
}

resource "aws_route_table" "VFQ-private-2" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${aws_instance.nat.id}"
    }

    tags {
        Name = "VFQ Private Subnet 2"
    }
}

resource "aws_route_table_association" "VFQ-private-2" {
    subnet_id = "${aws_subnet.VFQ-private-2.id}"
    route_table_id = "${aws_route_table.VFQ-private-2.id}"
}