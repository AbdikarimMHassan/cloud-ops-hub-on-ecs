variable "domain_name" {
    type = string
  
}

variable "alb_zone_id" {
    type = string
    description = "the zone_id  of the alb used by route 53 to map it to the alb"
  
}

variable "alb_dns_name" {
    type = string
    description = "alb dns name required to map domain to the alb"
  
}
