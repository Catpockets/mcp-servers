# RStudio Editor MCP

`mcpstudio` connects an MCP client to the live RStudio editor and active R session. It is an R package and local stdio server; it does not require Node, Docker, or a listening TCP port.

## Architecture

```text
Codex or another MCP client
    | MCP JSON-RPC over stdio
Rscript: mcptools::mcp_server()
    | authenticated same-user IPC socket
interactive RStudio R session
    | rstudioapi
live editor buffers and .GlobalEnv
```

Posit's `mcptools` creates the owner-only local socket directory and authenticates messages between the stdio process and interactive session. `rstudioapi` provides access to documents open in RStudio, including unsaved contents.

## Requirements

- R 4.1 or newer
- RStudio Desktop or RStudio Server with `rstudioapi` 0.19 or newer
- An MCP client with stdio support, such as Codex

## Install

Until a tagged release exists, install from GitHub:

```r
install.packages("remotes")
remotes::install_github(
  "Catpockets/mcp-servers",
  subdir = "servers/rstudio-editor"
)
```

## Start the RStudio session bridge

In the RStudio console, run:

```r
mcpstudio::start_session()
```

You can also use **Tools > Addins > Start RStudio MCP session**. The bridge stops when the R session exits; call `mcpstudio::stop_session()` to stop it earlier.

## Configure Codex

```bash
codex mcp add rstudio-editor -- Rscript -e "mcpstudio::mcp_server()"
codex mcp list
```

For fine-grained configuration:

```toml
[mcp_servers.rstudio_editor]
command = "Rscript"
args = ["-e", "mcpstudio::mcp_server()"]
default_tools_approval_mode = "writes"
startup_timeout_sec = 20
tool_timeout_sec = 130
```

When one RStudio session is active, the server selects it automatically. When several sessions are available and the MCP process working directory does not match one, use the supplied `list_r_sessions` and `select_r_session` tools deliberately.

## Tool safety

Read-only tools inspect local editor/session state. Editor mutations are marked as writes; full-buffer and range replacement are marked destructive. `rstudio_r_execute` can run arbitrary R code, access the network, change files, and mutate the active workspace, so it is marked destructive and open-world.

Keep the MCP client's write approval policy enabled. Returned execution output is capped at 20,000 characters by default and elapsed R evaluation is limited to 30 seconds by default. R's time limit cannot reliably interrupt every native extension, system call, or child process; treat execution as equivalent to running code manually in the RStudio console.

## Development

From this directory:

```bash
Rscript -e 'testthat::test_local()'
Rscript -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "warning")'
```

The test suite mocks the RStudio API for deterministic editor checks and launches the installed package over stdio to verify MCP initialization and tool discovery.
