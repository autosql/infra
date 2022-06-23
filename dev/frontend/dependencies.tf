data "terraform_remote_state" "vpc" {

  backend = "s3"

  config = {
    bucket = "autosql-infra-terraform-state"
    key = "env:/${terraform.workspace}/vpc/terraform.tfstate"
    region = "ap-northeast-2"
  }
}
