#' Unnest a fable column
#'
#' @param .data A nested tibble with a fable column
#' @param col The fable column to unnest
#' @param keep Other columns to keep
#'
#' @export
#'
#' @examples
ts_unnest_fable <- function(.data, col) {
  col <- enexpr(col)

  col_class <- eval_tidy(expr(class('$'(.data, !!col)[[1]])))[1]

  if (col_class != "fbl_ts") abort("unnest col must be a fable")

  keep_cols <- colnames(.data)[!map_lgl(.data, is.list)] %>%
    syms()

  suppressWarnings(
    .data %>%
      select(!!!keep_cols, !!col) %>%
      unnest_legacy(!!col) %>%
      ungroup() %>%
      mutate(.sd = map_dbl(.distribution, pluck, 2)) %>%
      select(-.distribution)
  )
}
