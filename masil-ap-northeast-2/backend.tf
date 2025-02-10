terraform {
  backend "s3" {
    bucket  = "mail-quick-ap-northeast-2-tfstate"
    key     = "terraform.tfstate"
    region  = "ap-northeast-2"
    encrypt = true
  }
}
