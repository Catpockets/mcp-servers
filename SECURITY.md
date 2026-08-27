# Security Policy

## Supported versions

Until the first stable release, security fixes are applied to the latest commit on `main` only.

## Reporting a vulnerability

Do not open a public issue. Use GitHub's **Report a vulnerability** flow in the repository Security tab to submit a private report.

Include the affected server, version or commit, reproduction steps, impact, and any suggested mitigation. Maintainers will acknowledge a report within seven days and coordinate disclosure after a fix is available.

## Trust model

MCP servers in this repository may expose powerful local capabilities. The RStudio server can change unsaved editor buffers and execute arbitrary R code in the active session. Users must keep write approvals enabled, review requested actions, and run only code they trust.
