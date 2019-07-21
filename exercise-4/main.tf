provider "aws" {
  region = "us-west-2"
}
#
# Create IAM Role and Policy for Lambda Function
#

resource "aws_iam_role" "lambda_s3_object_notification" {
  name = "lambda_s3_object_notification"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_s3_object_notification_policy" {
  name = "lambda_s3_object_notification_policy"
  role = "${aws_iam_role.lambda_s3_object_notification.id}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "ses:SendEmail",
                "ses:SendRawEmail"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

#
# Create Lambda Function
#

resource "aws_lambda_function" "lambda_s3_object_notification" {
  filename = "${local.zip_file_name}"
  source_code_hash = "${base64sha256(file("${local.zip_file_name}"))}"
  function_name    = "s3_object_notifications_via_ses"
  timeout		   = 10  
  role             = "${aws_iam_role.lambda_s3_object_notification.arn}"
  handler          = "lambda_s3_object_notification.lambda_handler"
  runtime          = "python2.7"
}
