output "dynamodb_table_arn" {
    value = aws_dynamodb_table.realtime-data-table.arn
}
output "dynamodb_table_name" {
    value = aws_dynamodb_table.realtime-data-table.name
}
