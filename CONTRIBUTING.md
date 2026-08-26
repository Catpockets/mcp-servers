# Contributing

Thank you for improving the MCP Servers project.

## Before coding

1. Search existing issues and discussions.
2. Open or claim a focused issue with observable acceptance criteria.
3. Create a branch that includes the issue number, such as `feature/123-short-description`.

## Development expectations

- Keep one MCP server per directory under `servers/`.
- Include tests for schemas, protocol startup, successful calls, and failure behavior.
- Mark all tool side effects accurately through MCP annotations.
- Never commit credentials, real datasets, local socket material, or generated user content.
- Add dependencies only when the maintenance and security benefit outweighs their supply-chain cost.

## Pull requests

Describe behavior, architecture and security implications, exact validation commands, and manual acceptance steps. Link the owning issue with an auto-close keyword. A maintainer will review and merge accepted changes after required checks pass.
