output "server_id" {
  value = hcloud_server.starkwolf.id
}

output "server_ipv4" {
  value = hcloud_server.starkwolf.ipv4_address
}

output "server_ipv6" {
  value = hcloud_server.starkwolf.ipv6_address
}
