variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "subnets" {
  description = "생성할 서브넷 설정"
  type = map(object({
    cidr_block        = string
    availability_zone = string
    type             = string  # public, private, data
  }))
}