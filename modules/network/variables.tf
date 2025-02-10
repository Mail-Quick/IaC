variable "vpc_name" {
}
variable "cidr_numeral" {
}

variable "aws_region" {
}

variable "availability_zones" {
  type = list(string)
}

variable "cidr_numeral_public" {
  type = map(string)
}

variable "cidr_numeral_private" {
  type = map(string)
}

variable "cidr_numeral_private_db" {
  type = map(string)
}
