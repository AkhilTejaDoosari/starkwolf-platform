variable "server_name" {
  description = "Hetzner server name"
  type        = string
  default     = "starkwolf"
}

variable "server_type" {
  description = "Hetzner server type"
  type        = string
}

variable "location" {
  description = "Hetzner location"
  type        = string
}

variable "image" {
  description = "Hetzner operating system image"
  type        = string
  default     = "ubuntu-24.04"
}

variable "ssh_key_name" {
  description = "Existing Hetzner SSH key name"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR permitted to reach SSH during bootstrap"
  type        = string
}
