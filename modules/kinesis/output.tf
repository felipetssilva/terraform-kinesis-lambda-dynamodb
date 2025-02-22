output "kinesis_stream_name" {
  value = aws_kinesis_stream.realtime-data-stream.name
  }

  output "kinesis_stream_arn" {
  value = aws_kinesis_stream.realtime-data-stream.arn
  }