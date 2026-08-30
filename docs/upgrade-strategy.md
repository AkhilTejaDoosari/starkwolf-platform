# Upgrade Strategy

Automatic production mutation is intentionally disabled.

Target workflow:

1. Renovate detects a supported dependency update.
2. Renovate opens a Pull Request.
3. CI validates configuration.
4. A human reviews the change.
5. The approved version is deployed deliberately.
6. Observability verifies platform health.
7. Rollback is available if verification fails.

Immich server and machine-learning releases are coordinated.
Immich PostgreSQL/VectorChord and Valkey dependencies are not independently
upgraded merely because a newer image exists.
