interactive_mode <- function() {
  interactive()
}

close_session_socket <- function(socket) {
  close(socket)
}

#' Connect the current RStudio session to the MCP server
#'
#' Registers the current interactive RStudio R session with `mcptools` using
#' authenticated same-user local IPC. Repeated calls return the existing
#' connection.
#'
#' @return The session socket, invisibly.
#' @export
start_session <- function() {
  if (!interactive_mode()) {
    abort_mcpstudio("`start_session()` must run in an interactive R session.")
  }
  require_rstudio()
  if (!is.null(.mcpstudio_state$session_socket)) {
    return(invisible(.mcpstudio_state$session_socket))
  }

  .mcpstudio_state$session_socket <- mcptools::mcp_session()
  message("RStudio MCP session started for ", normalizePath(getwd(), winslash = "/"), ".")
  invisible(.mcpstudio_state$session_socket)
}

#' Disconnect the current RStudio session from the MCP server
#'
#' @return `TRUE` when a connection was closed and `FALSE` when none existed,
#'   invisibly.
#' @export
stop_session <- function() {
  socket <- .mcpstudio_state$session_socket
  if (is.null(socket)) {
    return(invisible(FALSE))
  }

  close_session_socket(socket)
  .mcpstudio_state$session_socket <- NULL
  message("RStudio MCP session stopped.")
  invisible(TRUE)
}
