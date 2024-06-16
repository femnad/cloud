variable "checkly_api_key" {
  sensitive = true
}
variable "checkly_account_id" {
}

provider "checkly" {
  api_key    = var.checkly_api_key
  account_id = var.checkly_account_id
}

locals {
  mta_sts_host = nonsensitive(data.sops_file.secrets.data["mta_sts_host"])
}

resource "checkly_alert_channel" "email_main" {
  email {
    address = data.sops_file.secrets.data["checkly_main_email"]
  }
  send_recovery        = true
  send_failure         = true
  send_degraded        = true
  ssl_expiry           = true
  ssl_expiry_threshold = 7
}

resource "checkly_alert_channel" "email_push" {
  email {
    address = data.sops_file.secrets.data["checkly_push_email"]
  }
  send_recovery        = true
  send_failure         = true
  send_degraded        = true
  ssl_expiry           = true
  ssl_expiry_threshold = 7
}

resource "checkly_check" "mta-sts" {
  name                      = "mta-sts"
  type                      = "API"
  activated                 = true
  frequency                 = 10
  use_global_alert_settings = true

  locations = [
    "eu-west-2"
  ]

  request {
    url = "https://${local.mta_sts_host}/.well-known/mta-sts.txt"
    assertion {
      source     = "STATUS_CODE"
      comparison = "EQUALS"
      target     = "200"
    }
  }

  alert_channel_subscription {
    channel_id = checkly_alert_channel.email_main.id
    activated  = true
  }

  alert_channel_subscription {
    channel_id = checkly_alert_channel.email_push.id
    activated  = true
  }
}
