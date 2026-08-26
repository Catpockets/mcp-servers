r_execute_impl <- function(code, timeout_seconds = 30L, max_output_chars = 20000L) {
  assert_string(code, "code")
  if (nchar(code, type = "chars") > 100000L) {
    abort_mcpstudio("`code` must not exceed 100,000 characters.")
  }
  timeout_seconds <- assert_integerish(
    timeout_seconds,
    "timeout_seconds",
    minimum = 1L,
    maximum = 120L
  )
  max_output_chars <- assert_integerish(
    max_output_chars,
    "max_output_chars",
    minimum = 100L,
    maximum = 100000L
  )

  warnings <- character()
  messages <- character()
  started <- proc.time()[["elapsed"]]
  setTimeLimit(cpu = Inf, elapsed = timeout_seconds, transient = TRUE)
  on.exit(setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE), add = TRUE)

  captured <- utils::capture.output({
    outcome <- withCallingHandlers(
      withVisible(eval(parse(text = code, keep.source = FALSE), envir = .GlobalEnv)),
      warning = function(condition) {
        warnings <<- c(warnings, conditionMessage(condition))
        invokeRestart("muffleWarning")
      },
      message = function(condition) {
        messages <<- c(messages, conditionMessage(condition))
        invokeRestart("muffleMessage")
      }
    )
    if (isTRUE(outcome$visible)) {
      print(outcome$value)
    }
  })

  output <- truncate_text(captured, max_output_chars)
  list(
    ok = TRUE,
    output = output$text,
    output_truncated = output$truncated,
    warnings = warnings,
    messages = messages,
    value_class = class(outcome$value),
    elapsed_seconds = unname(proc.time()[["elapsed"]] - started)
  )
}
