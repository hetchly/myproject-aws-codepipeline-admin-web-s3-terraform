terraform {
  backend "s3" {
    region         = "ap-southeast-1"
    bucket         = "707538076348-ap-southeast-1-terraform-state"
    key            = "codepipeline-admin-web.tfstate"
    encrypt        = "true"
    dynamodb_table = "terraform-state-lock"
  }
}