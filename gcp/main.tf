terraform {
  backend "gcs" {
    bucket = "tf-fcd-sync"
    prefix = "cloud/gcp"
  }

  required_version = ">= 0.13"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.2.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "1.0.0"
    }
  }
}

locals {
  project = nonsensitive(data.sops_file.secrets.data["project"])
}

data "sops_file" "secrets" {
  source_file = "secrets.sops.yml"
}

provider "google" {
  project = local.project
  region  = "europe-west2"
  zone    = "europe-west2-c"
}
