resource "google_secret_manager_secret" "pushover-secret" {
  secret_id = "pushover"

  replication {
    user_managed {
      replicas {
        location = "us-west4"
      }
    }
  }
}

resource "google_secret_manager_secret_iam_binding" "pushover_role_binding" {
  secret_id = "pushover"
  role      = "roles/secretmanager.secretAccessor"
  members = [
    "serviceAccount:${google_service_account.pushover-service-account.email}"
  ]

  lifecycle {
    prevent_destroy = true
  }
}
