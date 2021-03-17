output "entries" {
  value = {
    s3_id = {
      log = aws_s3_bucket.aws_logs.id
    },
    s3_arn = {
      log = aws_s3_bucket.aws_logs.arn
    }
  }
}