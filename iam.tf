data "aws_iam_policy_document" "lambda_execution_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_execution_role" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_execution_policy.json
}

# Grant permission to read events from Kinesis
resource "aws_iam_policy_attachment" "lambda_execution_policy_attachment" {
  name       = "lambda_execution_policy_attachment"
  roles      = [aws_iam_role.lambda_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisReadOnlyAccess" # Attach a Kinesis read-only policy
}

# Grant permission to write Logs to CloudWatch
resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name        = "cloudwatch-logs-policy"
  description = "Policy to allow writing to CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "cloudwatch_logs_attachment" {
  name       = "cloudwatch_logs_attachment"
  roles      = [aws_iam_role.lambda_execution_role.name]
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}

# Grant permission to write data to DynamoDB
resource "aws_iam_policy" "dynamodb_write_policy" {
  name        = "dynamodb-write-policy"
  description = "Policy to allow writing to DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
        ],
        Effect   = "Allow",
        Resource = aws_dynamodb_table.realtime-data-table.arn
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "dynamodb_write_policy_attachment" {
  name       = "dynamodb_write_policy_attachment"
  roles      = [aws_iam_role.lambda_execution_role.name]
  policy_arn = aws_iam_policy.dynamodb_write_policy.arn
}
