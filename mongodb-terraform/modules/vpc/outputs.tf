output "vpc_id" {
  value = aws_vpc.main.id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}

output "mongodb_sg_id" {
  value = aws_security_group.mongodb_sg.id
}

# Output Public Route Table ID
output "public_route_table_id" {
  value = aws_route_table.public_rt.id
}

# Output Internet Gateway ID
output "igw_id" {
  value = aws_internet_gateway.igw.id
}
