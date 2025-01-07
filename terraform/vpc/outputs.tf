output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnets" {
  value = [for subnet in values(aws_subnet.public) : subnet.id]
}

output "private_subnets" {
  value = [for subnet in values(aws_subnet.private) : subnet.id]
}

output "nat_gateway_id" {
  value = var.enable_nat_gateway && var.single_nat_gateway ? aws_nat_gateway.this[0].id : null
}

