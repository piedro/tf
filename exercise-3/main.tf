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

resource "aws_vpc_endpoint" "s3" {
  vpc_id = "${aws_vpc.tech-test-vpc.id}"
  service_name = "com.amazonaws.us-west-2.s3"
  route_table_ids = [ "${aws_route_table.tech-test-public-subnet-route-table.id}"]
    policy = <<POLICY
    {
        "Statement": [
            {
                "Action": "*","Effect": "Allow","Resource": "*","Principal": "*"
            }
        ]
    }
    POLICY

  tags = {
    Environment = "test"
  }
}
