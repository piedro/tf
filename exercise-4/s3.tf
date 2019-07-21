#
# Configure S3 Object Notifications
#

data "aws_s3_bucket" "s3_bucket" {
  bucket = "ry-unique-name-terraform-state-file-storage"
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_s3_object_notification.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${data.aws_s3_bucket.s3_bucket.arn}"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "ry-unique-name-terraform-state-file-storage"
  lambda_function {
    lambda_function_arn = "${aws_lambda_function.lambda_s3_object_notification.arn}"
    events              = ["s3:ObjectCreated:Put"]
  }
}
