resource "aws_lambda_function" "image_resizer" {
  function_name = "image-resizer"
  role          = aws_iam_role.lambda_role.arn

  package_type = "Image"
  image_uri    = "${var.account_id}.dkr.ecr.${var.provider_region}.amazonaws.com/${var.ecr_repo_name}:latest"
  timeout      = 10
  memory_size  = 512

  environment {
    variables = {
      RESIZE_BUCKET = var.bucket_b
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_image_compression_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda_exec_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
        ]
        Resource = [
          "${aws_s3_bucket.bucket_a.arn}/*",
        ]
        Effect = "Allow"
      },
      {
        Action = [
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.bucket_b.arn}/*"
        ]
        Effect = "Allow"
      },
      {
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = [
          aws_sqs_queue.message.arn,
        ]
        Effect = "Allow"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*",
        Effect   = "Allow",
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_event_source_mapping" "lambda_sqs_mapping" {
  event_source_arn = aws_sqs_queue.message.arn
  function_name    = aws_lambda_function.image_resizer.function_name
  enabled          = true
}
