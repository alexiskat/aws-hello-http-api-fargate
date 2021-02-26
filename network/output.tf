
output "entries" {
  value = {
    vpc = {
      mainvpc_id = aws_vpc.main.id
    }
    subnet_id = {
      public_sub_1a_id  = aws_subnet.public_sub_1a.id
      public_sub_1b_id  = aws_subnet.public_sub_1b.id
      private_sub_1a_id = aws_subnet.private_sub_1a.id
      private_sub_1b_id = aws_subnet.private_sub_1b.id
    }
  }
}