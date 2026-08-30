# Disaster Recovery

Target recovery flow:

Terraform
→ recreate Hetzner infrastructure
→ Ansible configure host
→ Docker Compose deploy workloads
→ restore encrypted off-site backup
→ validate applications
→ validate Prometheus targets and alerts.

A final rebuild exercise will prove this workflow end-to-end.
