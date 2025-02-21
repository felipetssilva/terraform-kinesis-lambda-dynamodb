resource "aws_kinesis_stream" "realtime-data-stream" {
  name = "${var.environment}_stream"
  shard_count      = 2 
  retention_period = 24  

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }

  tags = {
    Name = "realtime-data-stream"
  }
}