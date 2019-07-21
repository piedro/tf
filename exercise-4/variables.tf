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
variable "instance_count" {
  default = "2"
}
variable "instance_type" {
  default = "t2.micro"
}
variable "ami" {
  default= "ami-0f2176987ee50226e"
}

variable "recipient" {
  default= "human.gold@gmail.com"
}
variable "subject" {
  default= "tech-test-lamba-s3"
}
variable "sender_email" {
  default= "human.gold@gmail.com"
}
variable "sender_name" {
  default= "human.gold"
}
