
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
  }
}

data "external" "versions" {
  program = ["${path.module}/scripts/versions.sh"]
}

locals {
  qemu_ga_version     = data.external.versions.result["qemu_ga_version"]
  amd_ucode_version   = data.external.versions.result["amd_ucode_version"]
  intel_ucode_version = data.external.versions.result["intel_ucode_version"]
  imager_version = data.external.versions.result["imager_version"]
  system_command = var.system_type == "amd" ? [
    "metal",
    "--system-extension-image",
    "ghcr.io/siderolabs/qemu-guest-agent:${local.qemu_ga_version}",
    "--system-extension-image",
    "ghcr.io/siderolabs/intel-ucode:${local.amd_ucode_version}"
    ] : [
    "metal",
    "--system-extension-image",
    "ghcr.io/siderolabs/qemu-guest-agent:${local.qemu_ga_version}",
    "--system-extension-image",
    "ghcr.io/siderolabs/intel-ucode:${local.intel_ucode_version}"
  ]
}

provider "docker" {}

resource "docker_image" "imager" {
  name = "ghcr.io/siderolabs/imager:${local.imager_version}"
}

resource "null_resource" "cleanup" {
  provisioner "local-exec" {
    command     = "mkdir -p output"
    working_dir = path.root
    when        = create
  }
}

resource "docker_container" "imager" {

  depends_on = [
    null_resource.cleanup,
    data.external.versions
  ]

  image      = docker_image.imager.image_id
  name       = "imager"
  privileged = true
  tty        = true
  rm         = true
  attach     = false
  command    = local.system_command
  volumes {
    container_path = "/dev"
    host_path      = "/dev"
  }
  volumes {
    container_path = "/out"
    host_path      = "${abspath(path.module)}/output"
  }
}

# Not sure how to get around this sleep as the container exists on it's own
# and terraform expects the container to keep running with attach = true
resource "time_sleep" "sleep" {
  depends_on = [
    docker_container.imager
  ]
  create_duration = "30s"
}

resource "null_resource" "copy_image" {
  depends_on = [
    time_sleep.sleep
  ]
  provisioner "remote-exec" {
    connection {
      host        = var.PROXMOX_IP
      user        = var.PROXMOX_USERNAME
      private_key = file("~/.ssh/id_rsa")
    }

    inline = [
      "rm -rf /root/talos",
      "mkdir /root/talos"
    ]
  }

  provisioner "file" {
    source      = "${path.root}/output/metal-amd64.raw.xz"
    destination = "/root/talos/talos.raw.xz"
    connection {
      type        = "ssh"
      host        = var.PROXMOX_IP
      user        = var.PROXMOX_USERNAME
      private_key = file("~/.ssh/id_rsa")
    }
  }
}

resource "null_resource" "uncompress_image" {
  depends_on = [null_resource.copy_image]
  provisioner "remote-exec" {
    connection {
      host        = var.PROXMOX_IP
      user        = var.PROXMOX_USERNAME
      private_key = file("~/.ssh/id_rsa")
    }

    inline = [
      "xz -v -d talos/talos.raw.xz"
    ]
  }
}

resource "null_resource" "create_template" {
  depends_on = [null_resource.uncompress_image]
  provisioner "remote-exec" {
    when = create
    connection {
      host        = var.PROXMOX_IP
      user        = var.PROXMOX_USERNAME
      private_key = file("~/.ssh/id_rsa")
    }
    script = "${path.root}/scripts/template.sh"
  }
}
