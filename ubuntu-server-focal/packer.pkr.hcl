# This is just for installing the proxmox plugin

packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.7"
      source = "github.com/hashicorp/proxmox"
    }
  }
}
