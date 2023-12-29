data "sops_file" "secrets" {
  source_file = "secrets.sops.yml"
}

locals {
  dns_name = nonsensitive(data.sops_file.secrets.data["mta_sts_dns"])
}

provider "google" {
  project = nonsensitive(data.sops_file.secrets.data["project"])
  # Cheap spot instances?
  region = "us-west4"
  zone   = "us-west4-b"
}

data "google_compute_image" "ubuntu-latest" {
  project     = "ubuntu-os-cloud"
  family      = "ubuntu-minimal-2204-lts"
  most_recent = true
}

resource "local_file" "shutdown-script" {
  filename        = var.shutdown_script
  file_permission = "0644"
  content = templatefile("${var.shutdown_script}.tpl", {
    secret_name    = nonsensitive(data.sops_file.secrets.data["pushover_secret.name"])
  })
}

module "instance" {
  source       = "femnad/instance-module/gcp"
  version      = "0.23.2"
  github_user  = "femnad"
  image        = data.google_compute_image.ubuntu-latest.self_link
  name         = "mta-sts"
  machine_type = "e2-micro"
  metadata = {
    shutdown-script = local_file.shutdown-script.content
  }
  service_account = nonsensitive(data.sops_file.secrets.data["service_account"])
  spot            = true
}

module "dns-module" {
  source           = "femnad/dns-module/gcp"
  version          = "0.9.0"
  dns_name         = local.dns_name
  instance_ip_addr = module.instance.instance_ip_addr
  managed_zone     = nonsensitive(data.sops_file.secrets.data["dns_zone_name"])
  providers = {
    google = google
  }
}

module "firewall-module" {
  version = "0.11.0"
  source  = "femnad/firewall-module/gcp"
  network = module.instance.network_name
  prefix  = "mta-sts-firewall"
  ip_mask = var.managed_connection ? 29 : 32
  ip_num  = var.managed_connection ? 7 : 1
  self_reachable = {
    "22" = "tcp"
  }
  world_reachable = {
    port_map = {
      "443" = "tcp"
    }
  }
  providers = {
    google = google
  }
}
