data "hcloud_ssh_key" "starkwolf" {
  name = var.ssh_key_name
}

resource "hcloud_firewall" "starkwolf" {
  name = "${var.server_name}-firewall"

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      var.ssh_allowed_cidr
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "80"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

resource "hcloud_server" "starkwolf" {
  name        = var.server_name
  server_type = var.server_type
  image       = var.image
  location    = var.location

  ssh_keys = [
    data.hcloud_ssh_key.starkwolf.id
  ]

  firewall_ids = [
    hcloud_firewall.starkwolf.id
  ]

  labels = {
    project    = "starkwolf"
    managed_by = "terraform"
  }
}
