#' Unnest a fable column
#'
#' @param .data A nested tibble with a fable column
#' @param col The fable column to unnest
#' @param keep Other columns to keep
#'
#' @export
#'
#' @examples
ts_unnest_fable <- function(.data, col, get_sd = FALSE) {
  col <- enexpr(col)

  col_class <- eval_tidy(expr(class('$'(.data, !!col)[[1]])))[1]

  if (col_class != "fbl_ts") abort("unnest col must be a fable")

  # Keep all columns that are not list columns
  keep_cols <- colnames(.data)[!map_lgl(.data, is.list)] %>%
    syms()

  .data <- suppressWarnings(
    .data %>%
      select(!!!keep_cols, !!col) %>%
      unnest_legacy(!!col)
  )

  if (get_sd) {
    .data %>%
      # If forecast is NA convert .distribution to list of 0s
      # This allows for extraction of sd without errors
      mutate(.distribution = fifelse(is.na(count), list(list(0, 0)), .distribution),
             .sd = map_dbl(.distribution, pluck, 2)) %>%
      select(-.distribution)
  } else {
    .data %>%
      select(-.distribution)
  }
}
