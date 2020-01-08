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
    frequency()

  if (is.null(h)) h <- ts_frequency
  if (length(h) > 1) abort("h must be a single number")

  time_class_fn <- if (ts_frequency == 12) {
    tsibble::yearmonth
  } else if (ts_frequency == 4) {
    tsibble::yearquarter
  }

  if (ts_frequency != 12 & ts_frequency != 4)
    abort("time-series must be monthly or quarterly")

  forecast_df <- .ts %>%
    # Forecast time-series
    mutate_at(vars(ends_with("model")),
              list(forecast = ~map(.x, forecast::forecast, h = h))) %>%
    # Convert time-series to tibble
    mutate_at(vars(ends_with("forecast")),
              ~.x %>% map(~as_tibble(.x, rownames = "index") %>%
                            clean_names()
              )) %>%
    # Remove "_model_" from names of forecasts
    rename_all(str_replace, "_model_", "_")

  model_count <- colnames(.ts) %>%
    str_detect("model") %>%
    sum()

  grouping_cols <- forecast_df %>% select(group_vars()) %>% colnames()

  if (model_count == 1) {
    forecast_df <- forecast_df %>%
      select(group_cols(), ends_with("model"), ends_with("forecast")) %>%
      mutate_at(vars(ends_with("model")), ~1) %>%
      pivot_longer(ends_with("model"), names_to = "model") %>%
      select(-value) %>%
      mutate(model = str_replace(model, "_model", "")) %>%
      group_by_at(vars(-ends_with("forecast"))) %>%
      select(group_cols(), everything()) %>%
      unnest(accuracy) %>%
      ungroup() %>%
      mutate(model = str_replace(model, "_model", ""))
  } else {
    forecast_df <- forecast_df %>%
      select(group_cols(), ends_with("forecast")) %>%
      pivot_longer(ends_with("forecast"), names_to = "model", values_to = "forecast") %>%
      mutate(model = str_replace(model, "_forecast", "")) %>%
      group_by_at(vars(-ends_with("forecast"))) %>%
      select(group_cols(), everything()) %>%
      unnest(forecast) %>%
      ungroup() %>%
      mutate(model = str_replace(model, "_model", ""))
  }

  if (ts_frequency == 12) {
    forecast_df <- forecast_df %>%
      mutate(index = str_c(str_sub(index, 5, 8),
                           str_sub(index, 1, 3),
                           sep = " ") %>%
               time_class_fn())
  } else {
    forecast_df <- forecast_df %>%
      mutate(index = time_class_fn(index))
  }
  forecast_df %>%
    arrange(grouping_cols, index)
}
