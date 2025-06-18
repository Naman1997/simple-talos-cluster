terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.78.2"
    }
  }
}

data "local_file" "ssh_public_key" {
  filename = pathexpand(var.ssh_key)
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.TARGET_NODE

  source_raw {
    data = <<-EOF
    #cloud-config
    users:
      - default
      - name: ${var.ha_proxy_user}
        groups:
          - sudo
        shell: /bin/bash
        ssh_authorized_keys:
          - ${trimspace(data.local_file.ssh_public_key.content)}
        sudo: ALL=(ALL) NOPASSWD:ALL
    runcmd:
        - apt update -y && apt dist-upgrade -y
        - apt install -y qemu-guest-agent haproxy net-tools unattended-upgrades
        - timedatectl set-timezone America/Toronto
        - systemctl enable qemu-guest-agent
        - systemctl enable --now haproxy
        - systemctl start qemu-guest-agent
        - chown -R ${var.ha_proxy_user}:${var.ha_proxy_user} /etc/haproxy/
        - echo "done" > /tmp/cloud-config.done
    EOF

    file_name = "cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type   = "iso"
  datastore_id   = "local"
  node_name      = var.TARGET_NODE
  url            = "https://cloud-images.ubuntu.com/oracular/current/oracular-server-cloudimg-amd64.img"
  upload_timeout = 1000
  overwrite      = false
}

resource "proxmox_virtual_environment_vm" "node" {
  name      = "haproxy"
  node_name = var.TARGET_NODE

  agent {
    enabled = true
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
  }

  network_device {
    bridge = var.DEFAULT_BRIDGE
  }

  provisioner "local-exec" {
    command = <<-EOT
      n=0
      until [ "$n" -ge 10 ]
      do
        echo "Attempt number: $n"
        ssh-keygen -R $ADDRESS
        if [ $? -eq 0 ]; then
          echo "Successfully removed $ADDRESS"
          break
        fi
        n=$((n+1)) 
        sleep $[ ( $RANDOM % 10 )  + 1 ]s
      done
    EOT
    environment = {
      ADDRESS = element(flatten(self.ipv4_addresses), 1)
    }
    when = destroy
  }

  provisioner "local-exec" {
    command = <<-EOT
      n=0
      until [ "$n" -ge 10 ]
      do
        echo "Attempt number: $n"
        ssh-keyscan -H $ADDRESS >> ~/.ssh/known_hosts
        ssh -q -o StrictHostKeyChecking=no ${var.ha_proxy_user}@$ADDRESS exit < /dev/null
        if [ $? -eq 0 ]; then
          echo "Successfully added $ADDRESS"
          break
        fi
        n=$((n+1)) 
        sleep $[ ( $RANDOM % 10 )  + 1 ]s
      done
    EOT
    environment = {
      ADDRESS = element(flatten(self.ipv4_addresses), 1)
    }
    when = create
  }

}