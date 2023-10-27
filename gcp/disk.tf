resource "google_compute_disk" "geheim_disk" {
  name = nonsensitive(data.sops_file.secrets.data["geheim_volume_name"])
  size = 10
  type = "pd-standard"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_resource_policy" "geheim-snapshot" {
  name = "geheim-snapshot-policy"
  snapshot_schedule_policy {
    schedule {
      weekly_schedule {
        day_of_weeks {
          day        = "SUNDAY"
          start_time = "06:00"
        }
      }
    }
    retention_policy {
      max_retention_days = 30
    }
  }
}

resource "google_compute_disk_resource_policy_attachment" "geheim-policy-attachment" {
  name = google_compute_resource_policy.geheim-snapshot.name
  disk = google_compute_disk.geheim_disk.name
}

resource "google_compute_disk" "muzak_disk" {
  name = nonsensitive(data.sops_file.secrets.data["muzak_volume_name"])
  size = 10
  type = "pd-standard"

  lifecycle {
    prevent_destroy = true
  }
}
