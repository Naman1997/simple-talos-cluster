variable "system_type" {
  description = "System type"
  type        = string

  validation {
    condition     = var.system_type == "intel" || var.system_type == "amd"
    error_message = "Valid values for system_type are 'intel' or 'amd'"
  }
}

# Hypervisor config
variable "PROXMOX_API_ENDPOINT" {
  description = "API endpoint for proxmox"
  type        = string
}

variable "PROXMOX_USERNAME" {
  description = "User name used to login proxmox"
  type        = string
}

variable "PROXMOX_PASSWORD" {
  description = "Password used to login proxmox"
  type        = string
}

variable "PROXMOX_IP" {
  description = "IP address for proxmox"
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

# Cluster config
variable "MASTER_COUNT" {
  description = "Number of masters to create (Should be an odd number)"
  type        = number
  validation {
    condition     = var.MASTER_COUNT % 2 == 1
    error_message = "Number of master nodes must be always odd. Learn more here: https://discuss.kubernetes.io/t/high-availability-host-numbers/13143/2"
  }
  validation {
    condition     = var.MASTER_COUNT != 0
    error_message = "Number of master nodes cannot be 0"
  }
}

variable "WORKER_COUNT" {
  description = "Number of workers to create"
  type        = number
}

variable "autostart" {
  description = "Enable/Disable VM start on host bootup"
  type        = bool
}

variable "master_config" {
  description = "Kubernetes master config"
  type = object({
    memory  = string
    vcpus   = number
    sockets = number
  })
}

variable "worker_config" {
  description = "Kubernetes worker config"
  type = object({
    memory  = string
    vcpus   = number
    sockets = number
  })
}

# HA Proxy config
variable "ha_proxy_server" {
  description = "IP address of server running haproxy"
  type        = string
}

variable "ha_proxy_user" {
  description = "User on ha_proxy_server that can modify '/etc/haproxy/haproxy.cfg' and restart haproxy.service"
  type        = string
}