output "address" {
  value       = data.external.address.result["address"]
  description = "IP Address of the node"
}

output "name" {
  value       = proxmox_virtual_environment_vm.node.name
  description = "Name of the node"
}