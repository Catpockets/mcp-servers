rstudio_available <- function() {
  rstudioapi::isAvailable()
}

require_rstudio <- function() {
  if (!rstudio_available()) {
    abort_mcpstudio(
      paste(
        "No active RStudio API is available.",
        "Run mcpstudio::start_session() in the target RStudio session first."
      )
    )
  }
  invisible(TRUE)
}

rstudio_call <- function(name, ...) {
  require_rstudio()
  do.call(getExportedValue("rstudioapi", name), list(...))
}

document_position <- function(line, column) {
  line <- assert_integerish(line, "line", minimum = 1L)
  column <- assert_integerish(column, "column", minimum = 0L)
  rstudio_call("document_position", line, column)
}

document_range <- function(start_line, start_column, end_line, end_column) {
  start_line <- assert_integerish(start_line, "start_line", minimum = 1L)
  start_column <- assert_integerish(start_column, "start_column", minimum = 0L)
  end_line <- assert_integerish(end_line, "end_line", minimum = 1L)
  end_column <- assert_integerish(end_column, "end_column", minimum = 0L)
  if (
    end_line < start_line ||
      (end_line == start_line && end_column < start_column)
  ) {
    abort_mcpstudio("The range end must not precede the range start.")
  }
  start <- document_position(start_line, start_column)
  end <- document_position(end_line, end_column)
  rstudio_call("document_range", start, end)
}

position_as_list <- function(position) {
  list(
    line = as.integer(position[[1L]]),
    column = as.integer(position[[2L]])
  )
}

range_as_list <- function(range) {
  list(
    start = position_as_list(range$start),
    end = position_as_list(range$end)
  )
}
