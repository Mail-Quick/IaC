variable "vpc_name" {
}

variable "cidr_numeral" {
}

variable "aws_region" {
}

variable "terraform_name" {
}

variable "availability_zones" {
  type = list(string)
  description = "AZ의 개수에 따라서 생성할 Subnet, NAT, IGW 갯수가 달라짐, 최대 2개를 생성할 예정"
}


variable "cidr_numeral_public" {
  default = {
    "0" = "0"
    "1" = "16"
  }
}

variable "cidr_numeral_private" {
  default = {
    "0" = "80"
    "1" = "96"
  }
}

variable "cidr_numeral_private_db" {
  default = {
    "0" = "160"
    "1" = "176"
  }
}

variable "access_key" {
  type      = string
  sensitive = true
}

variable "secret_key" {
  type      = string
  sensitive = true
}

