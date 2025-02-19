resource "aws_kinesis_stream" "realtime-data-stream" {
  name = "${var.environment}_stream"
  # shard_count      = 2  # Adjust the number of shards as needed
  # retention_period = 24  # Adjust the retention period in hours as needed

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }

  tags = {
    Name = "realtime-data-stream"
  }
}