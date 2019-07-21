provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "tech-test-vpc" {
  cidr_block           = "${var.vpc-cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "tech-test-vpc"
  }
}

resource "aws_subnet" "tech-test-public-subnet" {
  vpc_id            = "${aws_vpc.tech-test-vpc.id}"
  cidr_block        = "${var.subnet-cidr-public}"
  availability_zone = "${var.region}a"

  tags {
    Name = "tech-test-public-subnet"
  }
}

resource "aws_route_table" "tech-test-public-subnet-route-table" {
  vpc_id = "${aws_vpc.tech-test-vpc.id}"

  tags {
    Name = "tech-test-public-subnet-route-table"
  }
}

resource "aws_internet_gateway" "tech-test-internet-gateway" {
  vpc_id = "${aws_vpc.tech-test-vpc.id}"

  tags {
    Name = "tech-test-internet-gateway"
  }
}

resource "aws_route" "tech-test-public-subnet-route" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.tech-test-internet-gateway.id}"
  route_table_id         = "${aws_route_table.tech-test-public-subnet-route-table.id}"
}

resource "aws_route_table_association" "public-subnet-route-table-association" {
  subnet_id      = "${aws_subnet.tech-test-public-subnet.id}"
  route_table_id = "${aws_route_table.tech-test-public-subnet-route-table.id}"
}

resource "aws_key_pair" "tech-test-web-keypair" {
  public_key = "${file(pathexpand(var.public_key))}"
}

resource "aws_instance" "web-instance" {
  ami                         = "ami-047bb4163c506cd98"
  instance_type               = "t2.nano"
  vpc_security_group_ids      = ["${aws_security_group.tech-test-web-instance-security-group.id}"]
  subnet_id                   = "${aws_subnet.tech-test-public-subnet.id}"
  associate_public_ip_address = true
  key_name                    = "${aws_key_pair.tech-test-web-keypair.key_name}"

  tags {
    Name = "web-instance"
  }

  user_data = <<EOF
#!/bin/sh
yum install -y nginx
chgrp ec2-user /usr/share/nginx/html
chmod 775 /usr/share/nginx/html
rm -rf /usr/share/nginx/html/*
service nginx start
EOF

  provisioner "local-exec" {
    command     = "tar -zcvf artifacts.tar.gz *"
    working_dir = "artifacts"
  }

  provisioner "local-exec" {
    command = "sleep 10"
  }

  provisioner "file" {
    source      = "artifacts/artifacts.tar.gz"
    destination = "/var/tmp/artifacts.tar.gz"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file(pathexpand(var.private_key))}"
    }
  }

  provisioner "remote-exec" {
    inline = ["tar -zxvf /var/tmp/artifacts.tar.gz -C /usr/share/nginx/html"]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file(pathexpand(var.private_key))}"
    }
  }
}

resource "aws_security_group" "tech-test-web-instance-security-group" {
  vpc_id = "${aws_vpc.tech-test-vpc.id}"

  ingress = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "tech-test-web-instance-security-group"
  }
}

output "web_domain" {
  value = "${aws_instance.web-instance.public_dns}"
}
