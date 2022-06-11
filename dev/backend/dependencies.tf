data "terraform_remote_state" "vpc" {

  backend = "local"

  config = {
    path = "../vpc/terraform.tfstate.d/${terraform.workspace}/terraform.tfstate"
  }
}
