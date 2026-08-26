test_that("tool catalog is stable and annotations describe side effects", {
  tools <- mcp_tools()
  names <- vapply(tools, function(tool) tool@name, character(1))

  expect_length(tools, 11L)
  expect_setequal(
    names,
    c(
      "rstudio_editor_get_active",
      "rstudio_session_status",
      "rstudio_editor_open",
      "rstudio_editor_new",
      "rstudio_editor_set_contents",
      "rstudio_editor_insert",
      "rstudio_editor_replace_range",
      "rstudio_editor_set_cursor",
      "rstudio_editor_set_selection",
      "rstudio_editor_save",
      "rstudio_r_execute"
    )
  )

  by_name <- setNames(tools, names)
  expect_true(by_name$rstudio_editor_get_active@annotations$read_only_hint)
  expect_true(by_name$rstudio_editor_set_contents@annotations$destructive_hint)
  expect_true(by_name$rstudio_r_execute@annotations$destructive_hint)
  expect_true(by_name$rstudio_r_execute@annotations$open_world_hint)
})

test_that("stdio server initializes and lists RStudio tools", {
  skip_on_cran()
  testthat::local_mocked_bindings(
    interactive = function() TRUE,
    .package = "mcptools"
  )
  testthat::local_mocked_bindings(
    rstudio_call = function(name, ...) {
      if (name != "getActiveDocumentContext") {
        stop("Unexpected RStudio API call: ", name)
      }
      list(
        id = "ipc-document",
        path = "",
        contents = c("live_value <- 41", "live_value + 1"),
        selection = list(list(
          range = list(start = c(1L, 0L), end = c(1L, 4L)),
          text = "live"
        ))
      )
    },
    .package = "mcpstudio"
  )
  session_socket <- mcptools::mcp_session()
  withr::defer(close(session_socket))

  package_dir <- normalizePath(testthat::test_path("..", ".."), winslash = "/")
  server_expression <- sprintf(
    "pkgload::load_all(%s, quiet = TRUE); mcpstudio::mcp_server()",
    encodeString(package_dir, quote = "\"")
  )
  server <- processx::process$new(
    command = file.path(R.home("bin"), "Rscript"),
    args = c("-e", server_expression),
    stdin = "|",
    stdout = "|",
    stderr = "|"
  )
  withr::defer(server$kill())

  request <- function(id, method, params = NULL) {
    payload <- list(jsonrpc = "2.0", id = id, method = method)
    if (!is.null(params)) payload$params <- params
    server$write_input(paste0(jsonlite::toJSON(payload, auto_unbox = TRUE), "\n"))
    deadline <- Sys.time() + 10
    while (Sys.time() < deadline) {
      later::run_now(0.05)
      ready <- server$poll_io(100)
      if (identical(unname(ready[["output"]]), "ready")) {
        lines <- server$read_output_lines()
        for (line in lines) {
          parsed <- jsonlite::fromJSON(line, simplifyVector = FALSE)
          if (identical(parsed$id, id)) return(parsed)
        }
      }
      if (!server$is_alive()) {
        stop(paste(server$read_error_lines(), collapse = "\n"))
      }
    }
    stop("Timed out waiting for MCP response.")
  }

  initialized <- request(1L, "initialize", list(
    protocolVersion = "2025-06-18",
    capabilities = structure(list(), names = character()),
    clientInfo = list(name = "mcpstudio-tests", version = "1")
  ))
  expect_identical(initialized$result$protocolVersion, "2025-06-18")

  listed <- request(2L, "tools/list")
  tool_names <- vapply(listed$result$tools, function(tool) tool$name, character(1))
  expect_true("rstudio_editor_get_active" %in% tool_names)
  execute <- listed$result$tools[[which(tool_names == "rstudio_r_execute")]]
  expect_true(execute$annotations$destructiveHint)

  active <- request(3L, "tools/call", list(
    name = "rstudio_editor_get_active",
    arguments = structure(list(), names = character())
  ))
  expect_identical(active$result$structuredContent$document_id, "ipc-document")
  expect_match(active$result$structuredContent$contents, "live_value", fixed = TRUE)

  evaluated <- request(4L, "tools/call", list(
    name = "rstudio_r_execute",
    arguments = list(code = "40 + 2", timeout_seconds = 5L, max_output_chars = 100L)
  ))
  expect_true(evaluated$result$structuredContent$ok)
  expect_match(evaluated$result$structuredContent$output, "42", fixed = TRUE)
})
