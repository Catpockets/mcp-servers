#' Run the RStudio editor MCP server
#'
#' Starts a blocking local MCP server over standard input and output. The
#' server uses [mcptools::mcp_server()] to discover an interactive RStudio
#' session that has called [start_session()]. This function is intended for an
#' MCP client process, not the interactive RStudio console.
#'
#' @return This function does not return during normal operation.
#' @export
mcp_server <- function() {
  mcptools::mcp_server(tools = mcp_tools(), session_tools = TRUE)
}
