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
#' your_ts %>%
#'   ts_prep() %>%
#'   ts_model(forecast::auto.arima) %>%
ts_model <- function(.data, ...) {
  if (!is.data.frame(.data)) stop("dt_ must be a data.frame or data.table")
  .data <- as_dt(.data)

  if (!"time_series" %in% colnames(.data))
    abort("A time_series column must be included in the dataset to apply ts_model()")

  .fns <- enexprs(...)

  .data <- as_dt(.data)

  for (.fn in .fns) {

    log_flag <- if (str_detect(deparse(.fn), "log\\(.ts+")) {
      "_log1"
    } else if (str_detect(deparse(.fn), "log\\(.ts +")) {
      "_log1"
    } else if (str_detect(deparse(.fn), "log\\(.ts")) {
      "_log"
    } else {
      ""
    }

    col_name <- .fn %>%
      deparse() %>%
      dt_str_replace("forecast::", "") %>%
      dt_str_replace("auto\\.", "") %>%
      dt_str_replace("\\s*\\([^\\)]+\\)", "") %>%
      dt_str_replace("\\)", "") %>%
      dt_str_c(log_flag, "_model") %>%
      sym()

    .data %>%
      dt_mutate(!!col_name := dt_map(time_series, possibly(function(.ts) !!.fn, otherwise = NA)))
  }
  .data
}
