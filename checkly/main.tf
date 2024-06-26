terraform {
  backend "gcs" {
    bucket = "tf-fcd-sync"
    prefix = "cloud/mta-sts"
  }

  required_version = ">= 0.13"

  required_providers {
    checkly = {
      source  = "checkly/checkly"
      version = "1.7.6"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 4.75.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "1.0.0"
    }
  }
}
