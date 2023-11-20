terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.38.1"
    }
  }
}

resource "proxmox_virtual_environment_vm" "node" {
  name                = var.name
  on_boot             = var.autostart
  node_name           = var.target_node
  bios                = "ovmf"
  scsi_hardware       = "virtio-scsi-pci"
  timeout_shutdown_vm = 300

  memory {
    dedicated = var.memory
  }

  cpu {
    cores   = var.vcpus
    type    = "x86-64-v2"
    sockets = var.sockets
  }

  agent {
    enabled = true
    timeout = "10s"
  }

  clone {
    retries = 3
    vm_id   = 8000
  }

  network_device {
    model  = "virtio"
    bridge = var.default_bridge
  }
}

data "external" "address" {
  depends_on  = [proxmox_virtual_environment_vm.node]
  working_dir = path.root
  program     = ["bash", "scripts/ip.sh", "${lower(proxmox_virtual_environment_vm.node.network_device[0].mac_address)}"]
}
