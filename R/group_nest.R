ts_group_nest <- function(.data, ..., .key = "time_series") {

  dots <- enexprs(...)

  if (length(dots) == 0) {
    .data <- eval_tidy(expr(.data[, list(data = list(.SD))]))

    .data <- .data %>%
      rename(!!.key := data)
  } else {
    dots <- tidy_dots_selector(.data, ...)

    .data <- eval_tidy(expr(.data[, list(data = list(.SD)), by = list(!!!dots)]))

    .data <- .data %>%
      rename(!!.key := data)
  }
  as_tibble(.data)
}
