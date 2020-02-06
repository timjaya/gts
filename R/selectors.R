tidy_vec_selector <- function(.data, select_vars) {
  select_vars <- enexpr(select_vars)

  select_index <- tidyselect::eval_select(expr(!!select_vars), .data)
  data_names <- colnames(.data)

  select_vars <- data_names[select_index] %>%
    as.list() %>%
    map(sym)

  select_vars
}

tidy_dots_selector <- function(.data, ...) {

  select_index <- tidyselect::eval_select(expr(c(...)), .data)
  data_names <- colnames(.data)

  select_vars <- data_names[select_index] %>%
    as.list() %>%
    map(sym)

  select_vars
}
