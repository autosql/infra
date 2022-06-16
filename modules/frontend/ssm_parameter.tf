resource "aws_ssm_parameter" "landing" {
  for_each = toset(var.bucket_names)

  name = "/${var.app}/${var.env}/${local.tags["tier"]}/${each.value}"
  type = "String"
  value = aws_s3_bucket.frontend["${each.key}"].bucket 

  tags = merge(
    local.tags, {
      Name = "${local.tags["tier"]}-${each.value}-bucket"
    }
  )
}
