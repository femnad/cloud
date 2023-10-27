resource "google_storage_bucket" "muzak-bucket" {
  name                        = nonsensitive(data.sops_file.secrets.data["muzak_bucket_name"])
  location                    = nonsensitive(data.sops_file.secrets.data["muzak_bucket_location"])
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_project_iam_custom_role" "muzak-mounter-role" {
  role_id     = nonsensitive(data.sops_file.secrets.data["muzak_mounter_role"])
  title       = "Muzak Mounter Role"
  description = "Role for interacting with muzak bucket"
  permissions = ["storage.buckets.get", "storage.buckets.list", "storage.objects.get", "storage.objects.list"]

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_storage_bucket_iam_binding" "muzak_role_binding" {
  bucket = google_storage_bucket.muzak-bucket.name
  role   = google_project_iam_custom_role.muzak-mounter-role.name

  members = [
    "serviceAccount:${google_service_account.muzak-service-account.email}"
  ]

  lifecycle {
    prevent_destroy = true
  }
}
