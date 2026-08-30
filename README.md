# Starkwolf

**Production-Style Self-Hosted DevOps Platform on Hetzner**

Starkwolf is a real single-node platform built around controlled ingress,
private management, Docker Compose workloads, professional observability,
encrypted off-site backups, disaster recovery testing, and reproducible
infrastructure.

## Runtime

### Applications
- Jellyfin
- Navidrome
- Vaultwarden
- Immich
  - server
  - machine learning
  - PostgreSQL
  - Valkey

### Platform
- Caddy
- Pi-hole

### Observability
- Prometheus
- Grafana
- Alertmanager
- node_exporter
- cAdvisor
- Blackbox Exporter

## Engineering Control Plane

- Git source of truth
- GitHub Actions validation
- Renovate dependency updates
- controlled deployment and rollback
- Terraform for Hetzner provisioning
- Ansible for host configuration
- encrypted local/off-site backups
- tested restoration
