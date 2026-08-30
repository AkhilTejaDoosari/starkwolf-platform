# Networking

Starkwolf separates public application ingress from private operational access.

Caddy provides public HTTP/HTTPS ingress.

Tailscale is used for private management access.

Prometheus exporters normally remain internal to Docker networking rather than
being published directly to the Internet.
