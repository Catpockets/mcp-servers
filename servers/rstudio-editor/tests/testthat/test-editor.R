test_that("active document state is normalized", {
  testthat::local_mocked_bindings(
    rstudio_call = function(name, ...) {
      expect_identical(name, "getActiveDocumentContext")
      list(
        id = "doc-1",
        path = "/tmp/example.R",
        contents = c("x <- 1", "x"),
        selection = list(list(
          range = list(start = c(1L, 0L), end = c(1L, 1L)),
          text = "x"
        ))
      )
    },
    .package = "mcpstudio"
  )

  result <- mcpstudio:::editor_get_active_impl()
  expect_identical(result$document_id, "doc-1")
  expect_identical(result$contents, "x <- 1\nx")
  expect_identical(result$line_count, 2L)
  expect_identical(result$selections[[1L]]$range$start, list(line = 1L, column = 0L))
})

test_that("editor mutations call the intended RStudio APIs", {
  calls <- list()
  testthat::local_mocked_bindings(
    rstudio_call = function(name, ...) {
      calls[[length(calls) + 1L]] <<- c(list(name = name), list(...))
      if (name == "document_position") return(c(list(...)[[1L]], list(...)[[2L]]))
      if (name == "document_range") return(list(start = list(...)[[1L]], end = list(...)[[2L]]))
      invisible(TRUE)
    },
    .package = "mcpstudio"
  )

  mcpstudio:::editor_insert_impl("abc", line = 2L, column = 0L, document_id = "doc")
  mcpstudio:::editor_replace_range_impl("z", 1L, 0L, 1L, 1L, "doc")
  mcpstudio:::editor_set_contents_impl("complete", "doc")

  expect_true(any(vapply(calls, function(call) call$name == "insertText", logical(1))))
  expect_true(any(vapply(calls, function(call) call$name == "modifyRange", logical(1))))
  expect_true(any(vapply(calls, function(call) call$name == "setDocumentContents", logical(1))))
})

test_that("invalid positions fail before mutation", {
  expect_error(
    mcpstudio:::editor_insert_impl("x", line = 1L),
    "provided together"
  )
  expect_error(
    mcpstudio:::document_range(2L, 0L, 1L, 0L),
    "must not precede"
  )
})

test_that("missing RStudio gives an actionable error", {
  testthat::local_mocked_bindings(
    rstudio_available = function() FALSE,
    .package = "mcpstudio"
  )
  expect_error(mcpstudio:::require_rstudio(), "start_session")
})
