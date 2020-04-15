output "vpc_id" {
  description = "The VPC id"
  value = aws_vpc.default.id
}

output "public_subnet_ids" {
  description = "The ids of the created public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "The ids of the created private subnets"
  value       = aws_subnet.private[*].id
}
