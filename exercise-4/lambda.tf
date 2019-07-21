#
# Substitute Variables in the Lambda Function Template
#

data "template_file" "lambda_function" {
	template = "${file("${path.module}/template/lambda_s3_object_notification.py")}"
	vars {
		sender_email    = "${var.sender_email}"
		sender_name 	= "${var.sender_name}"
		recipient 		= "${var.recipient}"
		subject 		= "${var.subject}"
	}
}

#
# Render Templated Python Function
#

resource "local_file" "rendered_template" {
    content     = "${data.template_file.lambda_function.rendered}"
    filename 	= "${path.module}/rendered/lambda_s3_object_notification.py"
}

#
# Package Lambda Function Source Code in a ZIP Archive
#

data "archive_file" "lambda_s3_object_notification_zip" {
  type = "zip"
  output_path = "${path.module}/lambda_s3_object_notification.zip"
  source_dir = "${path.module}/rendered/"
  depends_on = ["local_file.rendered_template"]
}

locals {
  zip_file_name = "${substr(data.archive_file.lambda_s3_object_notification_zip.output_path, length(path.cwd) + 1, -1)}"
  depends_on = ["data.archive_file.lambda_s3_object_notification_zip"]
}

