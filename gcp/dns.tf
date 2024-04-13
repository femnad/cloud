locals {
  dns_name     = nonsensitive(data.sops_file.secrets.data["dns_name"])
  dns_zone     = nonsensitive(data.sops_file.secrets.data["dns_zone_name"])
  email_domain = nonsensitive(data.sops_file.secrets.data["email_domain"])
}

resource "google_dns_managed_zone" "base_zone" {
  name     = local.dns_zone
  dns_name = nonsensitive(data.sops_file.secrets.data["dns_name"])

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_dns_record_set" "base_mx" {
  managed_zone = local.dns_zone
  name         = local.dns_name
  project      = local.project
  rrdatas = [
    "10 in1-smtp.messagingengine.com.",
    "20 in2-smtp.messagingengine.com.",
  ]
  ttl  = 3600
  type = "MX"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_dns_record_set" "base_ns" {
  managed_zone = local.dns_zone
  name         = local.dns_name
  project      = local.project
  rrdatas = [
    "ns-cloud-d1.googledomains.com.",
    "ns-cloud-d2.googledomains.com.",
    "ns-cloud-d3.googledomains.com.",
    "ns-cloud-d4.googledomains.com.",
  ]
  ttl  = 21600
  type = "NS"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_dns_record_set" "base_soa" {
  managed_zone = local.dns_zone
  name         = local.dns_name
  project      = local.project
  rrdatas = [
    "ns-cloud-d1.googledomains.com. cloud-dns-hostmaster.google.com. 4 21600 3600 259200 300",
  ]
  ttl  = 21600
  type = "SOA"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_dns_record_set" "base_txt" {
  managed_zone = local.dns_zone
  name         = local.dns_name
  project      = local.project
  rrdatas = [
    "\"v=spf1 include:spf.messagingengine.com ?all\"",
  ]
  ttl  = 3600
  type = "TXT"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_dns_record_set" "dmarc_txt" {
  managed_zone = local.dns_zone
  name         = nonsensitive(data.sops_file.secrets.data["dmarc_dns"])
  project      = local.project
  rrdatas      = ["\"v=DMARC1; p=quarantine; sp=quarantine; rua=mailto:${nonsensitive(data.sops_file.secrets.data["dmarc_email"])}; aspf=s; adkim=s\""]
  ttl          = 3600
  type         = "TXT"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_dns_record_set" "fm_cnames" {
  for_each     = toset(["1", "2", "3"])
  managed_zone = local.dns_zone
  name         = "fm${each.key}._domainkey.${local.email_domain}"
  project      = local.project
  rrdatas      = ["fm${each.key}.${local.email_domain}dkim.fmhosted.com."]
  ttl          = 3600
  type         = "CNAME"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_dns_record_set" "sqrt26_cname" {
  managed_zone = local.dns_zone
  name         = nonsensitive(data.sops_file.secrets.data["sqrt26_dns"])
  project      = local.project
  rrdatas      = [nonsensitive(data.sops_file.secrets.data["sqrt26_cname"])]
  ttl          = 3600
  type         = "CNAME"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_dns_record_set" "mta-sts-txt" {
  project      = local.project
  managed_zone = local.dns_zone
  name         = nonsensitive(data.sops_file.secrets.data["mta_sts_txt"])
  rrdatas      = ["\"v=STSv1;\" \"id=20230803213802Z;\""]
  ttl          = 3600
  type         = "TXT"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_dns_record_set" "fly_cname" {
  managed_zone = local.dns_zone
  name         = nonsensitive(data.sops_file.secrets.data["mta_sts_name"])
  project      = local.project
  rrdatas      = [nonsensitive(data.sops_file.secrets.data["mta_sts_cname"])]
  ttl          = 3600
  type         = "CNAME"

  lifecycle {
    prevent_destroy = true
  }
}
