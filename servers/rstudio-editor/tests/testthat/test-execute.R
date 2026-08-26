test_that("R execution returns structured bounded output", {
  result <- mcpstudio:::r_execute_impl("1 + 1", timeout_seconds = 5L, max_output_chars = 100L)
  expect_true(result$ok)
  expect_match(result$output, "2", fixed = TRUE)
  expect_false(result$output_truncated)
  expect_identical(result$value_class, "numeric")
})

test_that("R execution truncates returned output", {
  result <- mcpstudio:::r_execute_impl(
    "cat(strrep('x', 1000))",
    timeout_seconds = 5L,
    max_output_chars = 100L
  )
  expect_true(result$output_truncated)
  expect_lte(nchar(result$output), 100L)
})

test_that("R execution validates limits", {
  expect_error(mcpstudio:::r_execute_impl("1", timeout_seconds = 0L), "at least 1")
  expect_error(mcpstudio:::r_execute_impl("1", max_output_chars = 99L), "at least 100")
})
