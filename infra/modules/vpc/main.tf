# create vpc resource
resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true


    tags = {
        name = var.vpc_name
    }
  
}

# create public subnets for the alb
resource "aws_subnet" "public_subnets" {
    for_each = var.public_subnets
    vpc_id = aws_vpc.main.id
    cidr_block = each.value.cidr_block
    availability_zone = each.value.availability_zone
    map_public_ip_on_launch = true

    tags = {
        name = "public-subnet-${each.key}"
        Tier = "public-subnet"
}
}
# create private subnets for the app
resource "aws_subnet" "private_app_subnets" {
    for_each = var.private_app_subnets
    vpc_id = aws_vpc.main.id
    cidr_block = each.value.cidr_block
    availability_zone = each.value.availability_zone
    map_public_ip_on_launch = false

    tags = {
        name = "private-subnet-${each.key}"
        Tier = "private-app"

}
}

# create internet gateway to enable internet access for the vpc
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id

    tags = {
      name = "igw"
    } 
}

# create public route table for the public subnets
resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.main.id

    route  {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    
    tags = {
      name = "public-subnet-rt"
    }


    }

# create private subnet route table
resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.main.id
    for_each = var.private_app_subnets

    route  {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.ngw[each.key].id
    }
    
    tags = {
      name = "private-app-rt"
    }

  
}
  
# associate public subnet with the public route table
resource "aws_route_table_association" "public_rt_association" {
    for_each = var.public_subnets
    subnet_id = aws_subnet.public_subnets[each.key].id
    route_table_id = aws_route_table.public_rt.id
}

# associate private subnet with the private route table
resource "aws_route_table_association" "private_rt_association" {
    for_each = var.private_app_subnets
    subnet_id = aws_subnet.private_app_subnets[each.key].id
    route_table_id = aws_route_table.private_rt[each.key].id
}
# create elastic ip for the nat gateway
resource "aws_eip" "nat" {
    for_each = var.public_subnets
    domain = "vpc"
    tags = {
      name= "NAT-EIP-${each.key}"
    }
  
}
# create nat gateway to provide internet access for the private subnets
resource "aws_nat_gateway" "ngw" {
    for_each = var.public_subnets
    allocation_id = aws_eip.nat[each.key].allocation_id
    subnet_id = aws_subnet.public_subnets[each.key].id
    depends_on = [ aws_internet_gateway.igw ]
    tags = {
      name = "nat-gateway-${each.key}"
    }
  
}

