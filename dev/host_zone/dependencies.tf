date "terraform_remote_state" "frontend" {

  backend = "local"

  config = {
    path = "../frontend"
  }
}

