
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
  }
}

provider "docker" {}

resource "docker_image" "imager" {
  name = "ghcr.io/siderolabs/imager:latest"
}

resource "null_resource" "cleanup" {
  provisioner "local-exec" {
    command     = "mkdir -p output"
    working_dir = path.root
    when = create
  }
}

resource "docker_container" "imager" {

  depends_on = [null_resource.cleanup]

  image      = docker_image.imager.image_id
  name       = "imager"
  privileged = true
  tty        = true
  rm         = true
  attach     = false
  command    = ["metal", "--system-extension-image", "ghcr.io/siderolabs/qemu-guest-agent:8.0.2", "--system-extension-image", "ghcr.io/siderolabs/intel-ucode:20230808"]
  volumes {
    container_path = "/dev"
    host_path      = "/dev"
  }
  volumes {
    container_path = "/out"
    host_path      = "${abspath(path.module)}/output"
  }
}
