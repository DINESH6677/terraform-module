variable "Vpc_CIDRBLOCK"{
    type = string
}

variable "project"{
    type = string
}

variable "environment"{
    type = string
}

variable "vpc_tester_tags"{
    type = map
    default = {}
}

variable "vpc-gw-tags"{
    type = map
    default = {}
}

variable "public_subnet_cidrs"{
    type = list
}

variable "public_subnet_tags"{
    type = map
    default = {}
}

variable "private_subnet_cidrs"{
    type = list
}

variable "private_subnet_tags"{
    type = map
    default = {}
}

variable "database_subnet_cidrs"{
    type = list
}

variable "database_subnet_tags"{
    type = map
    default = {}
}

variable "vpc-public-route-tags"{
    type = map
    default = {}
}

variable "vpc-private-route-tags"{
    type = map
    default = {}
}

variable "vpc-database-route-tags"{
    type = map
    default = {}
}

variable "vpc-eip-tags"{
    type = map
    default = {}
}

variable "vpc-nat-tags"{
    type = map
    default = {}
}