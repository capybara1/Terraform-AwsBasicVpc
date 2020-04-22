output "vpc_id" {
  description = "The VPC id"
  value       = aws_vpc.default.id
}

output "public_subnets" {
  description = "The ids of the created public subnets"
  value = [for i in range(var.number_of_public_subnets) : {
    id                     = aws_subnet.public[i].id,
    availability_zone_id   = data.aws_availability_zones.available.zone_ids[i],
    availability_zone_name = data.aws_availability_zones.available.names[i]
  }]
}

output "private_subnets" {
  description = "The ids of the created private subnets"
  value = [for i in range(var.number_of_private_subnets) : {
    id                     = aws_subnet.private[i].id,
    availability_zone_id   = data.aws_availability_zones.available.zone_ids[i],
    availability_zone_name = data.aws_availability_zones.available.names[i]
  }]
}
