data "uptimerobot_account_details" "this" {}

data "uptimerobot_alert_contact" "default" {
  type  = "e-mail"
  value = data.uptimerobot_account_details.this.email
}

resource "uptimerobot_monitor" "mta-sts" {
  friendly_name = "mta-sts"
  interval      = 300
  type          = "http"
  url           = "https://${trimsuffix(local.dns_name, ".")}/.well-known/mta-sts.txt"

  alert_contact {
    id = data.uptimerobot_alert_contact.default.id
  }
}
