# Starkwolf v1 Release Status

## Production state

Starkwolf is a production-style self-hosted DevOps platform running on a
Hetzner CPX32 VPS using Docker Compose.

The frozen runtime architecture contains exactly 15 active services.

### Applications

- Jellyfin
- Navidrome
- Vaultwarden
- Immich Server
- Immich Machine Learning
- Immich PostgreSQL
- Immich Valkey
- Pi-hole

### Platform

- Caddy
- Prometheus
- Grafana
- Alertmanager
- node_exporter
- cAdvisor
- Blackbox Exporter

## Proven controls

- Git is the source of truth.
- GitHub Actions validates Compose, shell scripts, Terraform and Ansible.
- Terraform was validated against the real Hetzner provider.
- The provider-backed recovery plan produced:

  `2 to add, 0 to change, 0 to destroy`

- No Terraform apply was performed for the v1 recovery proof.
- Ansible defines fresh-host Docker bootstrap.
- Prometheus/Grafana provide metrics and dashboards.
- Alertmanager email delivery was tested end-to-end.
- Six production alert rules are active.
- Backups are encrypted with GPG.
- Seven local encrypted backups are retained.
- Seven off-site backups are retained on pCloud.
- Local/off-site backup integrity was verified with SHA256.
- Immich PostgreSQL was restored into an isolated database and validated.
- Automatic production mutation through Watchtower was retired.
- Portainer, Watchtower, Netdata, Uptime Kuma, Kavita and the stale PDF
  workload were retired from the active architecture.

## Final gates

Final Engineering Gate:

- PASS: 24
- WARN: 0
- FAIL: 0
- RESULT: READY_FOR_FINAL_POLISH

Audit v2.1:

- HEALTH: 100/100
- RESULT: RELEASE_READY
- CRITICAL: 0
- ACTION REQUIRED: 0

Maintenance findings are tracked as v2 architecture/hardening backlog and are
not hidden or represented as completed work.

## v1 scope boundary

Starkwolf v1 does not claim:

- Kubernetes production operation
- multi-node high availability
- full second-host Terraform apply/rebuild proof
- centralized log aggregation
- managed cloud databases
- cross-cloud portability

These are deliberate future-learning or v2 topics, not missing v1 claims.
