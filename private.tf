/*
  Database Servers
*/
resource "aws_security_group" "db" {
    name = "vpc_db"
    description = "Allow incoming database connections."

    ingress { # The default port for mongod and mongos instances
        from_port = 27017
        to_port = 27017
        protocol = "tcp"
        security_groups = ["${aws_security_group.web.id}"]
    }
    ingress { # The default port when running with --shardsvr runtime operation or the shardsvr value for the clusterRole setting in a configuration file.
        from_port = 27018
        to_port = 27018
        protocol = "tcp"
        security_groups = ["${aws_security_group.web.id}"]
    }
    ingress { # The default port when running with --configsvr runtime operation or the configsvr value for the clusterRole setting in a configuration file.
        from_port = 27019
        to_port = 27019
        protocol = "tcp"
        security_groups = ["${aws_security_group.web.id}"]
    }
    ingress { # The default port for the web status page. The web status page is always accessible at a port number that is 1000 greater than the port determined by port.
        from_port = 28017
        to_port = 28017
        protocol = "tcp"
        security_groups = ["${aws_security_group.web.id}"]
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
        cidr_blocks = ["${var.vpc_cidr}"]
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
        Name = "VFQ DBServerSG"
    }
}

resource "aws_instance" "db-arbiter" {
    ami = "${lookup(var.db_ami, var.aws_region)}"
    availability_zone = "${var.az_1}"
    instance_type = "${var.db_arbiter_instance_type}"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.db.id}"]
    subnet_id = "${aws_subnet.VFQ-private-1.id}"
    source_dest_check = false

    tags {
        Name = "VFQ DB Arbiter"
    }

    # Destroy ec2 only if created successful
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_instance" "db-1" {
    ami = "${lookup(var.db_ami, var.aws_region)}"
    availability_zone = "${var.az_1}"
    instance_type = "${var.db_instance_type}"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.db.id}"]
    subnet_id = "${aws_subnet.VFQ-private-1.id}"
    source_dest_check = false

    tags {
        Name = "VFQ DB Server 1"
    }

    # Destroy ec2 only if created successful
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_instance" "db-2" {
    ami = "${lookup(var.db_ami, var.aws_region)}"
    availability_zone = "${var.az_2}"
    instance_type = "${var.db_instance_type}"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.db.id}"]
    subnet_id = "${aws_subnet.VFQ-private-2.id}"
    source_dest_check = false

    tags {
        Name = "VFQ DB Server 2"
    }

    # Destroy ec2 only if created successful
    lifecycle {
        create_before_destroy = true
    }
}

