#' Train a model
#'
#' @description
#' Train a model exported from the `forecast` package
#'
#' @param .ts A `gts`` prepped time-series
#' @param ... forecast functions passed
#'
#' @return A gts mable
#' @export
#' @md
#'
#' @examples
#' your_df %>%
#'   ts_prep(key = c(level_1, level_2), index = index, target = revenue)
#'   ts_model(ets(.ts),
#'            ets(log(.ts + 1)))
ts_model <- function(.data, ...) {
  if (!is.data.frame(.data)) stop("dt_ must be a data.frame or data.table")
  .data <- as_dt(.data)

  if (!"time_series" %in% colnames(.data))
    abort("A time_series column must be included in the dataset to apply ts_model()")

  .fns <- enexprs(...)

  .data <- as_dt(.data)

  for (.fn in .fns) {

    .fn_string <- deparse(.fn)

    paren_location <- .fn_string %>%
      str_locate("\\(") %>%
      .[1]

    col_name <- .fn_string %>%
      str_sub(1, paren_location - 1) %>%
      str_replace("forecast::", "") %>%
      str_replace("auto\\.", "")

    log_flag <- if (str_detect(deparse(.fn), "log\\(.ts\\+")) {
      "_log1"
    } else if (str_detect(deparse(.fn), "log\\(.ts \\+")) {
      "_log1"
    } else if (str_detect(deparse(.fn), "log\\(.ts")) {
      "_log"
    } else {
      ""
    }

    col_name <- col_name %>%
      str_c(log_flag, "_model") %>%
      sym()

    .data %>%
      dt_mutate(!!col_name := map(time_series, possibly(function(.ts) !!.fn, otherwise = NA)))
  }
  .data %>%
    dt_select(-time_series)
}
