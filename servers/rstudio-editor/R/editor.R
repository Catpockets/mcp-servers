editor_get_active_impl <- function() {
  context <- rstudio_call("getActiveDocumentContext")
  if (is.null(context$id) || !nzchar(context$id)) {
    abort_mcpstudio("RStudio has no active source document.")
  }

  selections <- lapply(context$selection, function(selection) {
    list(
      range = range_as_list(selection$range),
      text = paste(as.character(selection$text), collapse = "\n")
    )
  })
  contents <- paste(as.character(context$contents), collapse = "\n")

  list(
    document_id = context$id,
    path = if (nzchar(context$path)) context$path else NULL,
    contents = contents,
    line_count = if (nzchar(contents)) length(strsplit(contents, "\n", fixed = TRUE)[[1L]]) else 0L,
    selections = selections
  )
}

editor_open_impl <- function(path, line = -1L, column = -1L) {
  assert_string(path, "path")
  line <- assert_integerish(line, "line", minimum = -1L)
  column <- assert_integerish(column, "column", minimum = -1L)
  if (line == 0L || column == 0L) {
    abort_mcpstudio("`line` and `column` must be -1 or positive whole numbers.")
  }
  normalized <- normalizePath(path.expand(path), winslash = "/", mustWork = TRUE)
  if (dir.exists(normalized)) {
    abort_mcpstudio("`path` must identify a file, not a directory.")
  }

  document_id <- rstudio_call(
    "documentOpen",
    normalized,
    line = line,
    col = column,
    moveCursor = TRUE
  )
  list(opened = TRUE, document_id = document_id, path = normalized)
}

editor_new_impl <- function(text = "", type = "r") {
  assert_string(text, "text", allow_empty = TRUE)
  assert_string(type, "type")
  allowed <- c("r", "rmarkdown", "sql")
  if (!type %in% allowed) {
    abort_mcpstudio(sprintf("`type` must be one of: %s.", paste(allowed, collapse = ", ")))
  }

  document_id <- rstudio_call(
    "documentNew",
    text,
    type = type,
    position = c(0L, 0L),
    execute = FALSE
  )
  list(created = TRUE, document_id = document_id, type = type)
}

editor_set_contents_impl <- function(text, document_id = NULL) {
  assert_string(text, "text", allow_empty = TRUE)
  document_id <- normalize_document_id(document_id)
  rstudio_call("setDocumentContents", text, id = document_id)
  list(updated = TRUE, document_id = document_id)
}

editor_insert_impl <- function(text, line = NULL, column = NULL, document_id = NULL) {
  assert_string(text, "text", allow_empty = TRUE)
  document_id <- normalize_document_id(document_id)
  if (xor(is.null(line), is.null(column))) {
    abort_mcpstudio("`line` and `column` must be provided together or both omitted.")
  }
  location <- if (is.null(line)) NULL else document_position(line, column)
  rstudio_call("insertText", location = location, text = text, id = document_id)
  list(inserted = TRUE, document_id = document_id)
}

editor_replace_range_impl <- function(
  text,
  start_line,
  start_column,
  end_line,
  end_column,
  document_id = NULL
) {
  assert_string(text, "text", allow_empty = TRUE)
  document_id <- normalize_document_id(document_id)
  location <- document_range(start_line, start_column, end_line, end_column)
  rstudio_call("modifyRange", location = location, text = text, id = document_id)
  list(replaced = TRUE, document_id = document_id)
}

editor_set_cursor_impl <- function(line, column, document_id = NULL) {
  document_id <- normalize_document_id(document_id)
  position <- document_position(line, column)
  rstudio_call("setCursorPosition", position = position, id = document_id)
  list(updated = TRUE, document_id = document_id, cursor = position_as_list(position))
}

editor_set_selection_impl <- function(
  start_line,
  start_column,
  end_line,
  end_column,
  document_id = NULL
) {
  document_id <- normalize_document_id(document_id)
  selection <- document_range(start_line, start_column, end_line, end_column)
  rstudio_call("setSelectionRanges", ranges = list(selection), id = document_id)
  list(updated = TRUE, document_id = document_id, selection = range_as_list(selection))
}

editor_save_impl <- function(document_id = NULL) {
  document_id <- normalize_document_id(document_id)
  result <- rstudio_call("documentSave", id = document_id)
  list(saved = isTRUE(result), document_id = document_id)
}

session_status_impl <- function() {
  active <- tryCatch(editor_get_active_impl(), error = function(error) NULL)
  list(
    r_version = R.version.string,
    rstudio_version = as.character(rstudio_call("versionInfo")$version),
    working_directory = normalizePath(getwd(), winslash = "/", mustWork = TRUE),
    project = rstudio_call("getActiveProject"),
    active_document = active
  )
}
