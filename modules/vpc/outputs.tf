# modules/vpc/outputs.tf
output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "public_route_table_id" {
  value = aws_route_table.public.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.this.id
}
