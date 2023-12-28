resource "uptimerobot_monitor" "mta-sts" {
  friendly_name = "mta-sts"
  type          = "http"
  sub_type      = "https"
  url           = "http://${local.dns_name}/.well-known/mta-sts.txt"
}
