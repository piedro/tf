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

resource "aws_security_group" "tech-test-sg-elb" {
  name = "tech-test-sg-elb"
  vpc_id = "${aws_vpc.tech-test-vpc.id}"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "tech-test-lc" {
  associate_public_ip_address = true
  image_id = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name                    = "${aws_key_pair.tech-test-web-keypair.key_name}"
  security_groups = ["${aws_security_group.tech-test-sg-elb.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"
 
    user_data = <<EOF
#!/bin/sh
yum install -y nginx
chgrp ec2-user /usr/share/nginx/html
chmod 775 /usr/share/nginx/html
rm -rf /usr/share/nginx/html/*
aws s3 cp s3://ry-unique-name-terraform-state-file-storage/artifacts.tar.gz /tmp/artifacts-s3.tar.gz
rm -rf /usr/share/nginx/html/*
sleep 10
tar zxvf /tmp/artifacts-s3.tar.gz -C /usr/share/nginx/html/
service nginx start
#
sudo su -
yum update -y
curl -O https://bootstrap.pypa.io/get-pip.py
python get-pip.py
pip install awscli
yum install sssd realmd oddjob oddjob-mkhomedir samba-common samba-common-tools krb5-workstation openldap-clients policycoreutils-python
echo Packages are installed
sleep 10
cat >> /etc/rc.local <<EOE
aws s3 cp s3://ry-unique-name-terraform-state-file-storage/artifacts.tar.gz /tmp/artifacts-s3.tar.gz
rm -rf /usr/share/nginx/html/*
tar zxvf /tmp/artifacts-s3.tar.gz -C /usr/share/nginx/html/
EOE
EOF
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_autoscaling_group" "tech-test-ASG" {
  launch_configuration = "${aws_launch_configuration.tech-test-lc.id}"
  vpc_zone_identifier  = ["${aws_subnet.tech-test-public-subnet.id}"]
  availability_zones = ["us-west-2a","us-west-2b","us-west-2c","us-west-2d"]
  load_balancers = ["${aws_elb.tech-test-elb.name}"]
  health_check_type = "ELB"

  max_size = 10
  min_size = 2

  tag {
    key = "Name"
    value = "web-instance"
    propagate_at_launch = true
  }
}

data "aws_availability_zones" "all" {}

resource "aws_elb" "tech-test-elb" {
  name = "tech-test-elb"
  subnets            = ["${aws_subnet.tech-test-public-subnet.*.id}"]
  security_groups = ["${aws_security_group.tech-test-sg-elb.id}"]

  "listener" {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    interval = 30
    target = "HTTP:80/"
    timeout = 3
    unhealthy_threshold = 2
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
data "aws_instances" "web-instance" {
  instance_tags {
    Name = "web-instance"
  }
}
