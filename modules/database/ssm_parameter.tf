# ----- DB Instance Endpoint
resource "aws_ssm_parameter" "address" {
  name = "/${var.app}/${var.env}/${local.tags["tier"]}/address"
  type = "String"
  value = aws_db_instance.this.address

  tags = merge(
    local.tags, {
      Name = "${local.prefix}-${local.tags["tier"]}-address"
    }
  )
}

resource "aws_ssm_parameter" "password" {
  name = "/${var.app}/${var.env}/${local.tags["tier"]}/password"
  type = "SecureString"
  value = var.MYSQL_PASSWORD

  tags = merge(
    local.tags, {
      Name = "${local.prefix}-${local.tags["tier"]}-password"
    }
  )
}
