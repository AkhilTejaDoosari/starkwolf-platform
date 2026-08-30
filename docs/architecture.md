# Architecture

GitHub is the desired-state source.

Changes move through:

Renovate / engineer
→ Pull Request
→ CI validation
→ human approval
→ controlled deployment
→ Docker Compose
→ Prometheus verification
→ rollback when required.

Terraform provisions Hetzner infrastructure.

Ansible configures the operating system.

Docker Compose defines runtime workloads.

Encrypted backups restore application state.
