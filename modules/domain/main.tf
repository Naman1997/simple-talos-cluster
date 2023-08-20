terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}

resource "proxmox_vm_qemu" "node" {
  name                   = var.name
  memory                 = var.memory
  cores                  = var.vcpus
  sockets                = var.sockets
  onboot                 = var.autostart
  target_node            = var.target_node
  agent                  = 1
  clone                  = "talos-golden"
  full_clone             = true
  boot                   = "order=scsi0"
  cpu                    = "x86-64-v2"
  # automatic_reboot       = false
  define_connection_info = false
  scsihw = "virtio-scsi-pci"

  network {
    model  = "virtio"
    bridge = var.default_bridge
  }
}

data "external" "address" {
  depends_on = [ proxmox_vm_qemu.node ]
  working_dir = "${path.root}"
  program = ["bash", "scripts/ip.sh", "${lower(proxmox_vm_qemu.node.network[0].macaddr)}"]
}