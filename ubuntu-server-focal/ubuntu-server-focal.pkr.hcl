# Ubuntu Server Focal (20.04)
# ---
# Packer Template to create an Ubuntu Server Focal for Proxmox

# Variable Definitions
variable "proxmox_api_url" {
    type = string
    default = env("PROXMOX_API_URL")
}

variable "proxmox_api_token_id" {
    type = string
    default = env("PROXMOX_API_TOKEN_ID")
    sensitive = true
}

variable "proxmox_api_token_secret" {
    type = string
    default = env("PROXMOX_API_TOKEN_SECRET")
    sensitive = true
}

variable "proxmox_node" {
    type = string
    default = env("PROXMOX_NODE")
}

variable "packer_runner_host" {
    type = string
    default = env("PACKER_RUNNER_HOST")
}

locals {
 timestamp = formatdate("YYYYMMDD", timestamp())
}

# Resource Definiation for the VM Template
source "proxmox-iso" "ubuntu-server-focal" {
 
    # Proxmox Connection Settings
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    # (Optional) Skip TLS Verification
    insecure_skip_tls_verify = false
    
    # VM General Settings
    node = "${var.proxmox_node}"
    vm_id = "900"
    vm_name = "ubuntu-server-focal-v${local.timestamp}"
    template_description = "Ubuntu Server 20.04 (focal) image, generated on ${timestamp()}"

    # VM OS Settings
    # (Option 1) Local ISO File
    iso_file = "iso:iso/ubuntu-20.04.6-live-server-amd64.iso"
    # (Option 2) Download ISO
    #iso_url = "https://releases.ubuntu.com/20.04/ubuntu-20.04.6-live-server-amd64.iso"
    iso_checksum = "b8f31413336b9393ad5d8ef0282717b2ab19f007df2e9ed5196c13d8f9153c8b"
    iso_storage_pool = "iso"
    unmount_iso = true

    # VM System Settings
    qemu_agent = true

    # VM Hard Disk Settings
    scsi_controller = "virtio-scsi-pci"

    disks {
        disk_size = "10G"
        format = "qcow2"
        storage_pool = "local"
        type = "virtio"
    }

    # VM CPU Settings
    cores = "2"
    
    # VM Memory Settings
    memory = "2048" 

    # VM Network Settings
    network_adapters {
        model = "virtio"
        bridge = "vmbr1"
        firewall = "true"
    } 

    # VM Cloud-Init Settings
    cloud_init = true
    cloud_init_storage_pool = "local"

    # PACKER Boot Commands
    boot_command = [
        "<esc><wait><esc><wait>",
        "<f6><wait><esc><wait>",
        "<bs><bs><bs><bs><bs>",
        "autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ",
        "--- <enter>"
    ]
    boot = "c"
    boot_wait = "5s"

    # PACKER Autoinstall Settings
    http_directory = "http" 
    # (Optional) Bind IP Address and Port
    http_bind_address = "${var.packer_runner_host}"
    # http_port_min = 8802
    # http_port_max = 8802

    ssh_username = "sysadmin"

    # (Option 1) Add your Password here
    ssh_password = "PASSWORD_PLAIN"

    # Raise the timeout, when installation takes longer
    ssh_timeout = "20m"
}

# Build Definition to create the VM Template
build {

    name = "ubuntu-server-focal"
    sources = ["source.proxmox-iso.ubuntu-server-focal"]

    # Provisioning the VM Template with an inline shell command
    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt-get -y autoremove --purge",
            "sudo apt-get -y clean",
            "sudo apt-get -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo rm -f /etc/netplan/00-installer-config.yaml",
            "sudo sync"
        ]
    }

    # Provisioning the VM Template with a configuration file
    provisioner "file" {
        source = "files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    # Provisioning the VM Template with a shell command
    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }
}
