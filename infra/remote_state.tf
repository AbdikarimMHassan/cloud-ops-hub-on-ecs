# create s3 bucket for the terrafrom state file
resource "aws_s3_bucket" "terraform_state" {
  bucket              = "abdikarimh-state-bucket"
  object_lock_enabled = true


}

# enable versioning to keep copies of previous state file versions

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }

}
# specify the object lock mode config and duration for the remote state bucket
resource "aws_s3_bucket_object_lock_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    default_retention {
      mode = "GOVERNANCE"
      days = "30"
    }
  }

}
# create dynamodb table to lock tfstate during terraform apply to prevent drift
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform_locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

}