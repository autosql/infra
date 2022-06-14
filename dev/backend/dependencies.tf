data "terraform_remote_state" "vpc" {

  backend = "local"

  config = {
    path = "../infra/dev/vpc/terraform.tfstate.d/${terraform.workspace}/terraform.tfstate"
  }
}
