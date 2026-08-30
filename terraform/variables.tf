variable "server_name" {
  description = "Hetzner server name"
  type        = string
  default     = "starkwolf"
}

variable "server_type" {
  description = "Hetzner server type"
  type        = string

  validation {
    condition     = length(trimspace(var.server_type)) > 0
    error_message = "server_type must not be empty."
  }
}

variable "location" {
  description = "Hetzner location"
  type        = string

  validation {
    condition     = length(trimspace(var.location)) > 0
    error_message = "location must not be empty."
  }
}

variable "image" {
  description = "Hetzner operating system image"
  type        = string
  default     = "ubuntu-24.04"
}

variable "ssh_key_name" {
  description = "Existing Hetzner SSH key name"
  type        = string

  validation {
    condition     = length(trimspace(var.ssh_key_name)) > 0
    error_message = "ssh_key_name must not be empty."
  }
}

variable "ssh_allowed_cidr" {
  description = "CIDR permitted to reach SSH during bootstrap"
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_allowed_cidr, 0))
    error_message = "ssh_allowed_cidr must be a valid CIDR."
  }
}
