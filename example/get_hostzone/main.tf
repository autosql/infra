module "host_zone" {
  source = "../../global/host_zone"

  domain = "autosql.co.kr"
}

output "host_zone" {
  value = module.host_zone.current_zone
}
