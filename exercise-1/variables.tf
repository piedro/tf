variable "region" {
  default = "us-west-2"
}

variable "vpc-cidr" {
  default = "10.0.0.0/16"

}

variable "subnet-cidr-public" {
  default = "10.0.0.0/20"
}

# for the purpose of this exercise use the default key pair on your local system
variable "public_key" {
  default = "/root/.ssh/id_rsa.pub"
}

variable "private_key" {
  default = "/root/.ssh/id_rsa"
}
variable "cluster-name" {
  default = "terraform-s3-demo"
  type    = "string"
}
