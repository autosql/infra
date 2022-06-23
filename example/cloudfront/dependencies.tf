data "terraform_remote_state" "frontend" {

  backend = "local"

  config = {
    path = "../frontend/terraform.tfstate.d/${terraform.workspace}/terraform.tfstate"
  }
}

