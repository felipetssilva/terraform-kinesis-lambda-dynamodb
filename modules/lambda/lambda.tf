# Creates a Lambda function to handle events from Kinesis
resource "aws_lambda_function" "realtime_data_consume" {
  function_name    = "${var.environment}_handler"
  filename         = "${var.lambda_filename}.zip"
  source_code_hash = data.archive_file.python_lambda_package.output_base64sha256
  handler          = "realtime_data_consume.lambda_handler"
  runtime          = "python3.9"
  timeout          = 10
  role             = var.aws_iam_role_arn

  # Define the mapping between the Lambda function and the Kinesis stream
  depends_on = [var.kinesis_stream_arn]

  environment {
    variables = {
      DYNAMODB_TABLE = var.dynamodb_table_name
    }
  }

  tags = {
    Name = "realtime_data_consume"
  }
}

# Provides a Lambda event source mapping. This allows Lambda functions to get events from Kinesis
resource "aws_lambda_event_source_mapping" "realtime-data-mapping" {
  event_source_arn  = var.kinesis_stream_arn
  function_name     = aws_lambda_function.realtime_data_consume.function_name
  starting_position = "LATEST"
}

# Create the archive file from the python source code file to send to AWS Lambda.
data "archive_file" "python_lambda_package" {
  type        = "zip"
  source_file = "./code/${var.lambda_filename}.py"
  output_path = "${var.lambda_filename}.zip"
}
