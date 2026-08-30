# Ansible

Ansible configures the operating system after Terraform creates the Hetzner VPS.

Target responsibilities:

- base packages
- Starkwolf user and directories
- Docker installation/configuration
- firewall policy
- Tailscale prerequisites
- backup prerequisites
- service configuration required before Docker Compose deployment

The current playbook is the Phase 4 foundation and will be completed before the rebuild test.
