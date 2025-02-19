resource "aws_dynamodb_table" "realtime-data-table" {
  name         = "${var.environment}_table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  table_class  = "STANDARD"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "realtime-data-table"
  }
}