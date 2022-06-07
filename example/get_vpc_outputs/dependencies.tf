data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../../stage/vpc/terraform.tfstate.d/${terraform.workspace}/terraform.tfstate"
  }
}

output "result" {
  value = data.terraform_remote_state.vpc.outputs.vpc_id
}
