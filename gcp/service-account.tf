resource "google_service_account" "muzak-service-account" {
  account_id = nonsensitive(data.sops_file.secrets.data["muzak_service_account_id"])

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_service_account" "pushover-service-account" {
  account_id = nonsensitive(data.sops_file.secrets.data["pushover_service_account_id"])

  lifecycle {
    prevent_destroy = true
  }
}
