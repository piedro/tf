

resource "aws_s3_bucket_policy" "b" {
  bucket = "ry-unique-name-terraform-state-file-storage"

policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor1",
            "Effect": "Deny",
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::ry-unique-name-terraform-state-file-storage",
            "Principal": "*",
            "Condition": {
                "IpAddress": {
                    "aws:SourceIp": "0.0.0.0/0"
                },
                "NotIpAddress": {"aws:SourceIp": "10.0.0.0/16"} 
            }
        }
    ]
}
EOF
}
