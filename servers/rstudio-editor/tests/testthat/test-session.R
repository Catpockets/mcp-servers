test_that("session lifecycle is idempotent", {
  state <- get(".mcpstudio_state", asNamespace("mcpstudio"))
  old_socket <- state$session_socket
  withr::defer(state$session_socket <- old_socket)
  state$session_socket <- NULL
  closed <- FALSE

  testthat::local_mocked_bindings(
    interactive_mode = function() TRUE,
    require_rstudio = function() invisible(TRUE),
    close_session_socket = function(socket) closed <<- identical(socket, "socket"),
    .package = "mcpstudio"
  )
  testthat::local_mocked_bindings(
    mcp_session = function() "socket",
    .package = "mcptools"
  )

  expect_message(first <- start_session(), "started")
  expect_invisible(second <- start_session())
  expect_identical(first, second)
  expect_message(expect_true(stop_session()), "stopped")
  expect_true(closed)
  expect_false(stop_session())
})
