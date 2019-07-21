provider "aws" {
  region = "us-west-2"
}

locals {
  availability_zones = ["us-west-2a","us-west-2b","us-west-2c","us-west-2d"]
}


resource "aws_dynamodb_table" "terraform_state_locking_dynamodb" {
  name = "terraform-state-locking"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform State File Locking"
  }
}
resource "aws_s3_bucket" "terraform_state_s3_bucket" {
    bucket = "ry-unique-name-terraform-state-file-storage"

    versioning {
      enabled = true
    }

    lifecycle {
      prevent_destroy = true
    }

    tags = {
      Name = "Terraform State File Storage"
    }
}
#variable "key_name" {}
#
#resource "tls_private_key" "example" {
#  algorithm = "RSA"
#  rsa_bits  = 4096
#}
#
#resource "aws_key_pair" "generated_key" {
#  key_name   = "${var.key_name}"
#  public_key = "${tls_private_key.example.public_key_openssh}"
#}
#
#
