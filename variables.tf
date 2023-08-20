variable "system_type" {
  description = "System type"
  type        = string

  validation {
    condition = var.system_type == "intel" || var.system_type == "amd"
    error_message = "Valid values for system_type are 'intel' or 'amd'"
  }
}
