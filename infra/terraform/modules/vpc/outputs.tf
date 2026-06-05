output "vpc_id" {
  value = aws_vpc.this.id
}

output "private_subnets" {
  value = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]
}

output "public_subnets" {
  value = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]
}
output "private_route_table_id" {
  value = aws_route_table.private.id
}

output "public_route_table_id" {
  value = aws_route_table.public.id
}
