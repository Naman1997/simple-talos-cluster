variable "ha_proxy_user" {
  description = "Username for proxy VM"
  type        = string
}

variable "DEFAULT_BRIDGE" {
  description = "Bridge to use when creating VMs in proxmox"
  type        = string
}

variable "TARGET_NODE" {
  description = "Target node name in proxmox"
  type        = string
}

variable "ssh_key" {
  description = "Public SSH key to be authorized"
}