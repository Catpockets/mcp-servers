# Repository Engineering Guide

## Scope

This repository is a monorepo for independent MCP servers. Place each server in `servers/<server-name>` with its own runtime metadata, tests, and focused README.

## Architecture requirements

- Prefer the language and runtime native to the target application.
- Prefer local stdio and owner-only operating-system IPC for desktop integrations.
- Do not add an unauthenticated listening socket, telemetry, remote code download, or Docker requirement without an approved issue that explicitly calls for it.
- Every MCP tool must document its return shape and failure behavior and must set accurate MCP tool annotations.
- Treat arbitrary code execution, file writes, editor mutations, and UI mutations as write operations.
- Bound returned output and document resource-limit caveats for code-execution tools.

## Validation

- Run the server-specific test suite and package/build check documented in its README.
- Exercise MCP initialization and `tools/list` over the actual transport.
- Keep CI actions pinned to immutable commit SHAs.

## Delivery

Follow the global issue-first, task-branch, commit, push, and pull-request workflow. Never merge a pull request on behalf of the lead.
