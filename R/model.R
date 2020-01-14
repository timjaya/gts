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
ts_model <- function(.ts, .fn, with_log = FALSE, ...) {

  if (!"ts" %in% colnames(.ts))
    abort("A ts column must be included in the dataset to apply a function")

  function_name <- enexpr(.fn) %>%
      deparse() %>%
      str_replace("forecast::", "")

  if (!function_name %in% ls("package:forecast"))
    abort(str_glue("{function_name} is not exported by package:forecast"))

  if (with_log) {
    col_name <- function_name %>%
      str_replace("auto\\.", "") %>%
      str_c("_log_model") %>%
      sym()

    .ts %>%
      mutate(!!col_name := map(ts, possibly(function(.x) .fn(log(.x + 1), ...), otherwise = NA)))
  } else {
    col_name <- function_name %>%
      str_replace("auto\\.", "") %>%
      str_c("_model") %>%
      sym()

    .ts %>%
      mutate(!!col_name := map(ts, possibly(function(.x) .fn(.x, ...), otherwise = NA)))
  }
}
