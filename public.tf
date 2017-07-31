/*
  Web Servers
*/
resource "aws_security_group" "web" {
    name = "vpc_web"
    description = "Allow incoming HTTP connections."

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = ["${aws_security_group.nat.id}"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress { # The default port for mongod and mongos instances
        from_port = 27017
        to_port = 27017
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr_1}","${var.private_subnet_cidr_2}"]
    }
    egress { # The default port when running with --shardsvr runtime operation or the shardsvr value for the clusterRole setting in a configuration file.
        from_port = 27018
        to_port = 27018
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr_1}","${var.private_subnet_cidr_2}"]
    }
    egress { # The default port when running with --configsvr runtime operation or the configsvr value for the clusterRole setting in a configuration file.
        from_port = 27019
        to_port = 27019
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr_1}","${var.private_subnet_cidr_2}"]
    }
    egress { # The default port for the web status page. The web status page is always accessible at a port number that is 1000 greater than the port determined by port.
        from_port = 28017
        to_port = 28017
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr_1}","${var.private_subnet_cidr_2}"]
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
    vpc_id = "${aws_vpc.default.id}"

    tags {
        Name = "VFQ WebServerSG"
    }
}

resource "aws_instance" "web-1" {
    ami = "${lookup(var.web_ami, var.aws_region)}"
    availability_zone = "${var.az_1}"
    instance_type = "${var.web_instance_type}"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.web.id}"]
    subnet_id = "${aws_subnet.VFQ-public-1.id}"
    associate_public_ip_address = true
    source_dest_check = false

    tags {
        Name = "VFQ Web Server 1"
    }

    # Destroy ec2 only if created successful
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_eip" "web-1" {
    instance = "${aws_instance.web-1.id}"
    vpc = true
}

resource "aws_instance" "web-2" {
    ami = "${lookup(var.web_ami, var.aws_region)}"
    availability_zone = "${var.az_2}"
    instance_type = "${var.web_instance_type}"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.web.id}"]
    subnet_id = "${aws_subnet.VFQ-public-2.id}"
    associate_public_ip_address = true
    source_dest_check = false

    tags {
        Name = "VFQ Web Server 2"
    }

    # Destroy ec2 only if created successful
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_eip" "web-2" {
    instance = "${aws_instance.web-2.id}"
    vpc = true
}