provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.aws_region
}

module "network" {
  source                  = "../modules/network"
  availability_zones      = var.availability_zones
  aws_region              = var.aws_region
  cidr_numeral            = var.cidr_numeral
  vpc_name                = var.vpc_name
  cidr_numeral_public     = var.cidr_numeral_public
  cidr_numeral_private    = var.cidr_numeral_private
  cidr_numeral_private_db = var.cidr_numeral_private_db
}

module "rdb" {
  source      = "../modules/rdb"
  vpc_id      = module.network.vpc_id
  vpc_name    = var.vpc_name
  private_db1 = module.network.db_subnet_id1
  private_db2 = module.network.db_subnet_id2
  db_username = local.db_username
  db_password = local.db_password
}

module "storage" {
  source         = "../modules/storage"
  terraform_name = var.terraform_name
}

data "aws_ssm_parameter" "db_username" {
  name            = "/config/${var.terraform_name}/jdbc-username"
  with_decryption = true
}

data "aws_ssm_parameter" "db_password" {
  name            = "/config/${var.terraform_name}/jdbc-password"
  with_decryption = true
}

locals {
  db_username = data.aws_ssm_parameter.db_username.value
  db_password = data.aws_ssm_parameter.db_password.value
}