
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}

provider "proxmox" {
  pm_api_url      = var.PROXMOX_API_ENDPOINT
  pm_user         = "${var.PROXMOX_USERNAME}@pam"
  pm_password     = var.PROXMOX_PASSWORD
  pm_tls_insecure = true
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

# Not sure how to get around this sleep as the container exits on it's own after creating the image
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

resource "null_resource" "create_template" {
  depends_on = [null_resource.copy_image]
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

module "master_domain" {

  depends_on = [
    null_resource.create_template
  ]

  source         = "./modules/domain"
  count          = var.MASTER_COUNT
  name           = format("talos-master%s", count.index)
  memory         = var.master_config.memory
  vcpus          = var.master_config.vcpus
  sockets        = var.master_config.sockets
  autostart      = var.autostart
  default_bridge = var.DEFAULT_BRIDGE
  target_node    = var.TARGET_NODE
}

module "worker_domain" {

  depends_on = [
    null_resource.create_template
  ]

  source         = "./modules/domain"
  count          = var.WORKER_COUNT
  name           = format("talos-worker%s", count.index)
  memory         = var.worker_config.memory
  vcpus          = var.worker_config.vcpus
  sockets        = var.worker_config.sockets
  autostart      = var.autostart
  default_bridge = var.DEFAULT_BRIDGE
  target_node    = var.TARGET_NODE
}

# FIXME: Use ip addresses to configure talos
# resource "local_file" "master_ip_config" {
#   depends_on = [ module.master_domain ]
#   content = join(",", module.master_domain.*.address)
#   filename = "master_ip_config"
# }

# resource "local_file" "worker_ip_config" {
#   depends_on = [ module.worker_domain ]
#   content = join(",", module.worker_domain.*.address)
#   filename = "worker_ip_config"
# }