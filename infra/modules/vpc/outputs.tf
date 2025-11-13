# expose the vpc id to other modules
output "vpc_id" {
    value = aws_vpc.main.id
  
}

# provide the public subnets to other resouces outside this module
output "public_subnet_ids" {
    value = [ for s in aws_subnet.public_subnets : s.id ]
    description = "expose the public subnets to  other modules"
  
}

# provide the public subnets to other resouces outside this module
output "private_app_subnets_ids" {
    value = [ for s in aws_subnet.private_app_subnets : s.id ]
    description = "expose private subnets to other modules"
}

