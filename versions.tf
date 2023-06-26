terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.4.0"
    }
  }
  required_version = ">= 1.5"
}