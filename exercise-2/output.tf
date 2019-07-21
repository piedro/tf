
output "elb_dns_name" {
  value = "${aws_elb.tech-test-elb.dns_name}"
}

output "private-ips" {
  value = "${data.aws_instances.web-instance.private_ips}"
}

output "public-ips" {
  value = "${data.aws_instances.web-instance.public_ips}"
}

