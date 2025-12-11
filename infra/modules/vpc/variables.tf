
# variable for the vpc name
variable "vpc_name" {
  type = string
  
}


# variable for the cidr range of the vpc
variable "vpc_cidr" {
    description = "cidr range for the vpc"
    type = string
  

}

# variable of the public subnets of the vpc
variable "public_subnets" {
    description = "map of public subnets where the alb will be deployed"
    type= map(object({
      cidr_block = string
      availability_zone = string
    }))
  
}
# variable of the subnet where the ecs app will be deployed
variable "private_app_subnets" {
    description = "map of subnets of the ecs service running the app"
    type = map(object({
      cidr_block = string
      availability_zone = string
    }))
  
}

