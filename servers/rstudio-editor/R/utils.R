abort_mcpstudio <- function(message) {
  stop(message, call. = FALSE)
}

assert_string <- function(value, name, allow_empty = FALSE) {
  if (!is.character(value) || length(value) != 1L || is.na(value)) {
    abort_mcpstudio(sprintf("`%s` must be one non-missing string.", name))
  }
  if (!allow_empty && !nzchar(value)) {
    abort_mcpstudio(sprintf("`%s` must not be empty.", name))
  }
  invisible(value)
}

assert_integerish <- function(value, name, minimum = NULL, maximum = NULL) {
  if (
    !is.numeric(value) || length(value) != 1L || is.na(value) ||
      !is.finite(value) || value != as.integer(value)
  ) {
    abort_mcpstudio(sprintf("`%s` must be one whole number.", name))
  }
  value <- as.integer(value)
  if (!is.null(minimum) && value < minimum) {
    abort_mcpstudio(sprintf("`%s` must be at least %d.", name, minimum))
  }
  if (!is.null(maximum) && value > maximum) {
    abort_mcpstudio(sprintf("`%s` must be at most %d.", name, maximum))
  }
  value
}

normalize_document_id <- function(document_id) {
  if (is.null(document_id)) {
    return(NULL)
  }
  assert_string(document_id, "document_id")
  document_id
}

truncate_text <- function(text, limit) {
  text <- paste(as.character(text), collapse = "\n")
  if (nchar(text, type = "chars") <= limit) {
    return(list(text = text, truncated = FALSE))
  }

  marker <- "\n... output truncated ..."
  keep <- max(0L, limit - nchar(marker, type = "chars"))
  list(
    text = paste0(substr(text, 1L, keep), marker),
    truncated = TRUE
  )
}
