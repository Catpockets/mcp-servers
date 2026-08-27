# MCP Servers

Production-oriented, open source [Model Context Protocol](https://modelcontextprotocol.io/) servers maintained as a monorepo.

## Servers

| Server | Status | Purpose |
| --- | --- | --- |
| [RStudio Editor](servers/rstudio-editor) | Experimental | Gives MCP clients deliberate access to the live RStudio editor and active R session. |

Each server lives under `servers/`, owns its runtime and tests, and must document its transport, trust boundary, mutating tools, and installation procedure.

## Security posture

- Local integrations prefer same-user operating-system IPC over listening network ports.
- Tools declare MCP read-only, destructive, idempotent, and open-world hints.
- Mutating tools are expected to run behind client-side write approval policies.
- GitHub Actions dependencies are pinned to full commit SHAs and updated by Dependabot.
- Changes reach `main` only through protected pull requests with required checks.

See [SECURITY.md](SECURITY.md) before reporting a vulnerability and [CONTRIBUTING.md](CONTRIBUTING.md) before proposing a change.

## License

[MIT](LICENSE)
