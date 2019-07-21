terraform {
 backend "s3" {
 key = "exercise-3" 
 region = "us-west-2"
 bucket = "terraform-airwork-testbbbaaaa"
 dynamodb_table = "terraform-state-locking"
 encrypt = true # Optional, S3 Bucket Server Side Encryption
 }
}
