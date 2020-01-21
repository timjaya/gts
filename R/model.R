#' Train a model
#'
#' @description
#' Train a model exported from the `forecast` package
#'
#' @param .ts A `gts`` prepped time-series
#' @param .fn A function exported by the `forecast` pacakge
#' @param with_log TRUE/FALSE whether a log transform should be applied
#' @param ... Additional parameters passed to the `forecast` function
#'
#' @return A gts mable
#' @export
#' @md
#'
#' @examples
#' your_ts %>%
#'   ts_prep() %>%
#'   ts_model(forecast::auto.arima) %>%
#'   ts_model(forecast::ets, with_log = TRUE)
ts_model <- function(.data, .fn, with_log = FALSE, ...) {
  if (!is.data.frame(.data)) stop("dt_ must be a data.frame or data.table")
  .data <- as_dt(.data)

  if (!"time_series" %in% colnames(.data))
    abort("A time_series column must be included in the dataset to apply ts_model()")

  function_name <- enexpr(.fn) %>%
    deparse() %>%
    dt_str_replace("forecast::", "")

  if (!function_name %in% ls("package:forecast"))
    abort(str_glue("{function_name} is not exported by package:forecast"))

  if (with_log) {
    col_name <- function_name %>%
      dt_str_replace("auto\\.", "") %>%
      dt_str_c("_log_model") %>%
      sym()

    .ts %>%
      dt_mutate(!!col_name := map(time_series, possibly(function(.x) .fn(log(.x + 1), ...), otherwise = NA)))
  } else {
    col_name <- function_name %>%
      dt_str_replace("auto\\.", "") %>%
      dt_str_c("_model") %>%
      sym()

    .data %>%
      dt_mutate(!!col_name := map(time_series, possibly(function(.x) .fn(.x, ...), otherwise = NA)))
  }
}
