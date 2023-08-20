
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
  qemu_ga_version = data.external.versions.result["qemu_ga_version"]
  amd_ucode_version  = data.external.versions.result["amd_ucode_version"]
  intel_ucode_version  = data.external.versions.result["intel_ucode_version"]
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
  name = "ghcr.io/siderolabs/imager:latest"
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

resource "time_sleep" "sleep" {
  depends_on = [
    docker_container.imager
  ]
  create_duration = "15s"
}