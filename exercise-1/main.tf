provider "aws" {
  region = "us-west-2"
}

locals {
  availability_zones = ["us-west-2a","us-west-2b","us-west-2c","us-west-2d"]
}

resource "aws_vpc" "tech-test-vpc" {
  cidr_block           = "${var.vpc-cidr}"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "tech-test-vpc"
  }
}

resource "aws_subnet" "tech-test-public-subnet" {
  vpc_id = "${aws_vpc.tech-test-vpc.id}"
  cidr_block        = "${var.subnet-cidr-public}"
  availability_zone = "${var.region}a"

  tags = {
    Name = "tech-test-public-subnet"
  }
}

resource "aws_route_table" "tech-test-public-subnet-route-table" {
  vpc_id = "${aws_vpc.tech-test-vpc.id}"

  tags = {
    Name = "tech-test-public-subnet-route-table"
  }
}

resource "aws_internet_gateway" "tech-test-internet-gateway" {
  vpc_id = "${aws_vpc.tech-test-vpc.id}"

  tags = {
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
  ami                         = "ami-0f2176987ee50226e"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["${aws_security_group.tech-test-web-instance-security-group.id}"]
  subnet_id                   = "${aws_subnet.tech-test-public-subnet.id}"
  key_name                    = "${aws_key_pair.tech-test-web-keypair.key_name}"
  associate_public_ip_address = true
  iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"

  tags = {
    Name = "web-instance"
  }

  user_data = <<EOF
#!/bin/sh
yum install -y nginx
chgrp ec2-user /usr/share/nginx/html
chmod 775 /usr/share/nginx/html
rm -rf /usr/share/nginx/html/*
service nginx start
sleep 5
cat >> /etc/rc.local <<EOE
aws s3 cp s3://ry-unique-name-terraform-state-file-storage/artifacts.tar.gz /tmp/artifacts-s3.tar.gz
rm -rf /usr/share/nginx/html/*
tar zxvf /tmp/artifacts-s3.tar.gz -C /usr/share/nginx/html/
EOE
EOF

  provisioner "local-exec" {
    command     = "tar -zcvf artifacts.tar.gz *"
    working_dir = "artifacts"
  }

  provisioner "local-exec" {
    command = "sleep 20"
  }

  provisioner "file" {
    source      = "artifacts/artifacts.tar.gz"
    destination = "/tmp/artifacts.tar.gz"

    connection {
      host        = "${aws_instance.web-instance.public_ip}"
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file(pathexpand(var.private_key))}"
    }
  }

  provisioner "remote-exec" {
    inline = ["tar -zxvf /tmp/artifacts.tar.gz -C /usr/share/nginx/html"]

    connection {
      host        = "${aws_instance.web-instance.public_ip}"
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file(pathexpand(var.private_key))}"
    }
  }
  provisioner "remote-exec" {
    inline = ["aws s3 cp /tmp/artifacts.tar.gz s3://ry-unique-name-terraform-state-file-storage"]

    connection {
      host        = "${aws_instance.web-instance.public_ip}"
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file(pathexpand(var.private_key))}"
    }
  }
}


resource "aws_security_group" "tech-test-web-instance-security-group" {
  vpc_id = "${aws_vpc.tech-test-vpc.id}"
  description = "sg"
  ingress = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "ingress 80"    
      self = true
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

  tags = {
    Name = "tech-test-web-instance-security-group"
  }
}

output "web_domain" {
  value = "${aws_instance.web-instance.public_dns}"
}
