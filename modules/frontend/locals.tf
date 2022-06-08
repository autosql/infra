locals {
  tags = {
    app = var.app
    managed = "terraform"
    env = var.env
  }
  prefix = "${var.app}-${var.env}"
}
