resource "aws_iam_role" "test_role" {
  name = "test_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ssm.amazonaws.com",
        "Service": "ec2.amazonaws.com",
        "Service": "s3.amazonaws.com",
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
      tag-key = "tag-value"
  }
}
resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = "${aws_iam_role.test_role.name}"
}
resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = "${aws_iam_role.test_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "resource-groups:*",
        "cloudformation:DescribeStackResources",
        "cloudformation:ListStackResources",
        "tag:GetResources",
        "tag:TagResources",
        "tag:UntagResources",
        "tag:getTagKeys",
        "tag:getTagValues"
      ],
      "Resource": "*"
    },
   {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "test_attach" {
  role       = "${aws_iam_role.test_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_ssm_activation" "foo" {
  name               = "test_activation"
  description        = "Test"
  iam_role           = "${aws_iam_role.test_role.id}"
  registration_limit = "10"
  depends_on         = ["aws_iam_role_policy_attachment.test_attach"]
}
resource "aws_ssm_document" "tech-test-ssm-document" {
  name          = "tech-test-ssm-document"
  document_type = "Command"
content = <<DOC
  {
     "schemaVersion":"2.0",
      "description":"Run a Shell script to securely install the dependencies for domain join",
      "mainSteps":[
         {
            "action":"aws:runShellScript",
            "name":"runShellScript",
            "inputs":{
            "runCommand": [
                    "sudo su -\n",
                    "yum update -y\n",
                    "curl -O https://bootstrap.pypa.io/get-pip.py\n",
                    "python get-pip.py\n",
                    "pip install awscli\n",
                    "yum install sssd realmd oddjob oddjob-mkhomedir samba-common samba-common-tools krb5-workstation openldap-clients policycoreutils-python -y\n",
                    "echo Packages are installed",
                    "aws s3 ls s3://ry-unique-name-terraform-state-file-storage/\n",
                    "aws s3 sync s3://ry-unique-name-terraform-state-file-storage/artifacts.tar.gz /tmp/artifacts-s3.tar.gz\n",
                    "tar zxvf /tmp/artifacts-s3.tar.gz -C /usr/share/nginx/html/ \n",
                    "touch /tmp/1.txt \n",
                    "echo files are updated from s3"

           ]
          }
      }

    ]
  }
DOC
}
resource "aws_ssm_association" "tech-test-association" {
  name = "${aws_ssm_document.tech-test-ssm-document.name}"
  targets {
  key = "tag:Name",
  values = ["web-instance"]
  }
}
