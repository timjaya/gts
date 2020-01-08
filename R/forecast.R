#' Create forecasts
#'
#' @description
#' Create forecasts from a `gts` mable.
#'
#' @param .ts A `gts` mable
#' @param h The number of periods to forecast. If NULL, forecasts the frequency of the input time-series.
#'
#' @return A tibble
#' @export
#'
#' @examples
#' your_ts %>%
#'   ts_prep() %>%
#'   ts_model(forecast::auto.arima) %>%
#'   ts_model(forecast::ets, with_log = TRUE)
#'
#' your_mbl %>%
#'   ts_forecast(h = 12)
ts_forecast <- function(.ts, h = NULL) {

  if (!any(str_detect(colnames(.ts), "model")))
    abort("Model columns not detected in the dataset")

  ts_frequency <- .ts %>%
    pull(ts) %>%
    pluck(1) %>%
    forecast::findfrequency()

  if (is.null(h)) h <- ts_frequency
  if (length(h) > 1) abort("h must be a single number")

  time_class_fn <- if (ts_frequency == 52) {
    tsibble::yearweek
  } else if (ts_frequency == 12) {
    ts_frequency == 12 ~ tsibble::yearquarter
  } else if (ts_frequency == 4) {
    tsibble::yearquarter
  } else {
    stop("time series are of an unsupported frequency")
  }

  .ts %>%
    # Forecast time-series
    mutate_at(vars(ends_with("model")),
              list(forecast = ~map(.x, forecast::forecast, h = h))) %>%
    # Convert time-series to tibble
    mutate_at(vars(ends_with("forecast")),
              ~.x %>% map(~as_tibble(.x, rownames = "index") %>%
                            clean_names() %>%
                            mutate(index = time_class_fn(index)))) %>%
    # Remove "_model_" from names of forecasts
    rename_all(str_replace, "_model_", "_") %>%
    # Back-transform any log forecasts
    mutate_at(vars(ends_with("log_forecast")),
              ~map(.x, ~.x %>% mutate(point_forecast = exp(point_forecast)))) %>%
    # Remove unnecessary columns
    select(group_cols(), ends_with("model"), ends_with("forecast")) %>%
    # Overwrite model objects with 1 to reduce size of data
    mutate_at(vars(ends_with("model")), ~1) %>%
    pivot_longer(ends_with("model"), names_to = "model") %>%
    select(-value) %>%
    pivot_longer(ends_with("forecast"), values_to = "forecast") %>%
    # Remove duplicate column labeling models
    select(-name) %>%
    # Group by all variables that aren't forecasts
    group_by_at(vars(-ends_with("forecast"))) %>%
    select(group_cols(), everything()) %>%
    # Unnest results
    unnest(ends_with("forecast")) %>%
    ungroup() %>%
    mutate(index = time_class_fn(index)) %>%
    mutate(model = str_replace(model, "_model", ""))
}
