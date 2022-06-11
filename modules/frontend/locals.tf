locals {
  tags = {
    app = var.app
    managed = "terraform"
    env = var.env
    tier = "frontend"
  }
  prefix = "${var.app}-${var.env}"
}
