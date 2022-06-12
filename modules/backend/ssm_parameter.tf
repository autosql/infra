resource "aws_ssm_parameter" "repository" {
  name = "/${var.app}/${var.env}/${local.tags["tier"]}/repository"
  type = "String"
  value = aws_ecr_repository.this.repository_url

  tags = merge(
    local.tags, {
      Name = "${local.tags["tier"]}-repository"
    }
  )
}

resource "aws_ssm_parameter" "address" {
  name = "/${var.app}/${var.env}/${local.tags["tier"]}/address"
  type = "String"
  value = aws_route53_record.main.fqdn

  tags = merge(
    local.tags, {
      Name = "${local.tags["tier"]}-address"
    }
  )
}
