variable "name" {
  description = "Name of node"
  type        = string
}

variable "memory" {
  description = "Amount of memory needed"
  type        = string
}

variable "vcpus" {
  description = "Number of vcpus"
  type        = number
}

variable "sockets" {
  description = "Number of sockets"
  type        = number
}

variable "autostart" {
  description = "Enable/Disable VM start on host bootup"
  type        = bool
}

variable "default_bridge" {
  description = "Bridge to use when creating VMs in proxmox"
  type        = string
}

variable "target_node" {
  description = "Target node name in proxmox"
  type        = string
}