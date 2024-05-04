resource "aws_s3_bucket" "bucket_a" {
  bucket        = var.bucket_a
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "bucket_a" {
  bucket                  = aws_s3_bucket.bucket_a.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "bucket_b" {
  bucket        = var.bucket_b
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "bucket_b" {
  bucket                  = aws_s3_bucket.bucket_b.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_notification" "bucket_a_notification" {
  bucket = aws_s3_bucket.bucket_a.id

  queue {
    queue_arn = aws_sqs_queue.message.arn
    events    = ["s3:ObjectCreated:*"]
  }
  # Permissions on the destination queue do not allow S3 to publish notifications from this bucket(宛先キューのパーミッションが、S3がこのバケットから通知を発行することを許可していない)
  depends_on = [aws_sqs_queue_policy.message_policy]
}
