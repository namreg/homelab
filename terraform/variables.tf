variable "proxmox_endpoint" {
  description = "HTTPS URL of the Proxmox API."
  type        = string

  validation {
    condition     = can(regex("^https://[^/]+/$", var.proxmox_endpoint))
    error_message = "Use an HTTPS URL with a trailing slash."
  }
}

variable "guest_ipv4_address" {
  description = "Static IPv4 address and prefix length for lab-01."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.guest_ipv4_address))
    error_message = "Use an IPv4 address with a valid prefix length."
  }
}

variable "ipv4_gateway" {
  description = "IPv4 gateway for the guest network."
  type        = string

  validation {
    condition     = can(cidrnetmask("${var.ipv4_gateway}/32"))
    error_message = "Use an IPv4 address without a prefix length."
  }
}
