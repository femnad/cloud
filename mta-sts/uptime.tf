resource "uptimerobot_monitor" "mta-sts" {
  friendly_name = "mta-sts"
  type          = "http"
  url           = "https://${trimsuffix(local.dns_name, ".")}/.well-known/mta-sts.txt"
}
