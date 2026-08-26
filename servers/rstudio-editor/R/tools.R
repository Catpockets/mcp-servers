#' MCP tools for the RStudio editor
#'
#' @return A list of `ellmer::ToolDef` objects suitable for
#'   [mcptools::mcp_server()].
#' @export
mcp_tools <- function() {
  closed_read <- ellmer::tool_annotations(
    read_only_hint = TRUE,
    idempotent_hint = TRUE,
    open_world_hint = FALSE
  )

  list(
    ellmer::tool(
      editor_get_active_impl,
      name = "rstudio_editor_get_active",
      description = paste(
        "Read the active RStudio source document, including its document ID,",
        "path when saved, complete live contents (including unsaved edits),",
        "line count, selected text, and selection ranges. Fails when no",
        "RStudio session bridge or active source document is available."
      ),
      annotations = closed_read
    ),
    ellmer::tool(
      session_status_impl,
      name = "rstudio_session_status",
      description = paste(
        "Read local R and RStudio versions, working directory, active project,",
        "and active-document metadata. Returns active_document as null when",
        "there is no active source document."
      ),
      annotations = closed_read
    ),
    ellmer::tool(
      editor_open_impl,
      name = "rstudio_editor_open",
      description = paste(
        "Open an existing local file in RStudio and optionally move the cursor.",
        "The path must exist. Use -1 for line and column to leave the cursor",
        "unspecified. This changes RStudio UI state but does not alter the file."
      ),
      arguments = list(
        path = ellmer::type_string("Existing local file path to open."),
        line = ellmer::type_integer("One-based line or -1 to leave unspecified.", required = FALSE),
        column = ellmer::type_integer("One-based column or -1 to leave unspecified.", required = FALSE)
      ),
      annotations = ellmer::tool_annotations(
        read_only_hint = FALSE,
        destructive_hint = FALSE,
        idempotent_hint = TRUE,
        open_world_hint = FALSE
      )
    ),
    ellmer::tool(
      editor_new_impl,
      name = "rstudio_editor_new",
      description = paste(
        "Create a new unsaved RStudio source document without executing it.",
        "Supported types are r, rmarkdown, and sql. Repeated calls create",
        "additional documents."
      ),
      arguments = list(
        text = ellmer::type_string("Initial document text; may be empty.", required = FALSE),
        type = ellmer::type_enum(c("r", "rmarkdown", "sql"), "RStudio document type.", required = FALSE)
      ),
      annotations = ellmer::tool_annotations(
        read_only_hint = FALSE,
        destructive_hint = FALSE,
        idempotent_hint = FALSE,
        open_world_hint = FALSE
      )
    ),
    ellmer::tool(
      editor_set_contents_impl,
      name = "rstudio_editor_set_contents",
      description = paste(
        "Replace the complete live contents of one RStudio document.",
        "This changes the in-memory editor buffer and may overwrite unsaved",
        "work. Omit document_id to target the active or last-active editor."
      ),
      arguments = list(
        text = ellmer::type_string("Complete replacement text; may be empty."),
        document_id = ellmer::type_string("RStudio document ID; omit for the active editor.", required = FALSE)
      ),
      annotations = ellmer::tool_annotations(
        read_only_hint = FALSE,
        destructive_hint = TRUE,
        idempotent_hint = TRUE,
        open_world_hint = FALSE
      )
    ),
    ellmer::tool(
      editor_insert_impl,
      name = "rstudio_editor_insert",
      description = paste(
        "Insert text into a live RStudio buffer. Omit both line and column to",
        "insert at the current selection or cursor; otherwise provide both.",
        "Editor positions use one-based lines and zero-based columns."
      ),
      arguments = list(
        text = ellmer::type_string("Text to insert; may be empty."),
        line = ellmer::type_integer("One-based line.", required = FALSE),
        column = ellmer::type_integer("Zero-based column.", required = FALSE),
        document_id = ellmer::type_string("RStudio document ID; omit for the active editor.", required = FALSE)
      ),
      annotations = ellmer::tool_annotations(
        read_only_hint = FALSE,
        destructive_hint = FALSE,
        idempotent_hint = FALSE,
        open_world_hint = FALSE
      )
    ),
    ellmer::tool(
      editor_replace_range_impl,
      name = "rstudio_editor_replace_range",
      description = paste(
        "Replace an exact range in a live RStudio buffer. The end must not",
        "precede the start. Positions use one-based lines and zero-based",
        "columns. This may overwrite unsaved work."
      ),
      arguments = list(
        text = ellmer::type_string("Replacement text; may be empty."),
        start_line = ellmer::type_integer("One-based start line."),
        start_column = ellmer::type_integer("Zero-based start column."),
        end_line = ellmer::type_integer("One-based end line."),
        end_column = ellmer::type_integer("Zero-based end column."),
        document_id = ellmer::type_string("RStudio document ID; omit for the active editor.", required = FALSE)
      ),
      annotations = ellmer::tool_annotations(
        read_only_hint = FALSE,
        destructive_hint = TRUE,
        idempotent_hint = FALSE,
        open_world_hint = FALSE
      )
    ),
    ellmer::tool(
      editor_set_cursor_impl,
      name = "rstudio_editor_set_cursor",
      description = paste(
        "Move the cursor in a live RStudio document without changing text.",
        "Positions use one-based lines and zero-based columns."
      ),
      arguments = list(
        line = ellmer::type_integer("One-based line."),
        column = ellmer::type_integer("Zero-based column."),
        document_id = ellmer::type_string("RStudio document ID; omit for the active editor.", required = FALSE)
      ),
      annotations = ellmer::tool_annotations(
        read_only_hint = FALSE,
        destructive_hint = FALSE,
        idempotent_hint = TRUE,
        open_world_hint = FALSE
      )
    ),
    ellmer::tool(
      editor_set_selection_impl,
      name = "rstudio_editor_set_selection",
      description = paste(
        "Set one selection range in a live RStudio document without changing",
        "text. Positions use one-based lines and zero-based columns."
      ),
      arguments = list(
        start_line = ellmer::type_integer("One-based start line."),
        start_column = ellmer::type_integer("Zero-based start column."),
        end_line = ellmer::type_integer("One-based end line."),
        end_column = ellmer::type_integer("Zero-based end column."),
        document_id = ellmer::type_string("RStudio document ID; omit for the active editor.", required = FALSE)
      ),
      annotations = ellmer::tool_annotations(
        read_only_hint = FALSE,
        destructive_hint = FALSE,
        idempotent_hint = TRUE,
        open_world_hint = FALSE
      )
    ),
    ellmer::tool(
      editor_save_impl,
      name = "rstudio_editor_save",
      description = paste(
        "Save one RStudio document to its existing path. Omit document_id to",
        "target the active editor. Unsaved new documents without a path may",
        "require interactive RStudio handling and can fail."
      ),
      arguments = list(
        document_id = ellmer::type_string("RStudio document ID; omit for the active editor.", required = FALSE)
      ),
      annotations = ellmer::tool_annotations(
        read_only_hint = FALSE,
        destructive_hint = FALSE,
        idempotent_hint = TRUE,
        open_world_hint = FALSE
      )
    ),
    ellmer::tool(
      r_execute_impl,
      name = "rstudio_r_execute",
      description = paste(
        "Execute arbitrary R code synchronously in the active RStudio global",
        "environment and return bounded visible output, warnings, messages,",
        "value class, and elapsed time. The default elapsed limit is 30 seconds",
        "and returned output limit is 20,000 characters. This can modify files,",
        "workspace state, processes, packages, and remote systems."
      ),
      arguments = list(
        code = ellmer::type_string("R code to parse and execute; maximum 100,000 characters."),
        timeout_seconds = ellmer::type_integer("Elapsed limit from 1 to 120 seconds.", required = FALSE),
        max_output_chars = ellmer::type_integer("Returned output limit from 100 to 100,000 characters.", required = FALSE)
      ),
      annotations = ellmer::tool_annotations(
        read_only_hint = FALSE,
        destructive_hint = TRUE,
        idempotent_hint = FALSE,
        open_world_hint = TRUE
      )
    )
  )
}
