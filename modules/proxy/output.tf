output "proxy_ipv4_address" {
  value = proxmox_virtual_environment_vm.node.ipv4_addresses[1][0]
}