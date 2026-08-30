output "server_id" {
  description = "Hetzner server ID"
  value       = hcloud_server.starkwolf.id
}

output "server_name" {
  description = "Hetzner server name"
  value       = hcloud_server.starkwolf.name
}

output "server_ipv4" {
  description = "Public IPv4 address"
  value       = hcloud_server.starkwolf.ipv4_address
}

output "server_ipv6" {
  description = "Public IPv6 address"
  value       = hcloud_server.starkwolf.ipv6_address
}

output "firewall_id" {
  description = "Hetzner firewall ID"
  value       = hcloud_firewall.starkwolf.id
}
