resource "uptimerobot_monitor" "mta-sts" {
  friendly_name = "mta-sts"
  interval      = 3600
  type          = "http"
  url           = "https://${trimsuffix(local.dns_name, ".")}/.well-known/mta-sts.txt"
}
