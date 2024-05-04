resource "aws_sqs_queue" "message" {
  name                      = "message"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
}

resource "aws_sqs_queue" "message_dlq" {
  name = "message-dlq"
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.message.arn]
  })
}

resource "aws_sqs_queue_redrive_policy" "message" {
  queue_url = aws_sqs_queue.message.id
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.message_dlq.arn
    maxReceiveCount     = 1
  })
}

resource "aws_sqs_queue_policy" "message_policy" {
  queue_url = aws_sqs_queue.message.url

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.message.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" : aws_s3_bucket.bucket_a.arn
          }
        }
      },
    ]
  })
}
