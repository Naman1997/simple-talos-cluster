output "address" {
  value       = data.external.address.result["address"]
  description = "IP Address of the node"
}

output "name" {
  value       = proxmox_vm_qemu.node.name
  description = "Name of the node"
}