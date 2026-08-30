# Security Model

Key principles:

- public exposure limited to required application ingress
- private operational services remain private
- secrets are not committed to Git
- automated production mutation is disabled
- changes are validated before deployment
- encrypted off-site backups are maintained
- rollback assets are preserved during risky changes
- unnecessary Docker socket consumers are removed
