#' Create forecasts
#'
#' @description
#' Create forecasts from a `gts` mable.
#'
#' @param .ts A `gts` mable
#' @param h The number of periods to forecast. Defaults to 12
#'
#' @return A tibble
#' @export
#'
#' @examples
#' your_mbl <- your_df %>%
#'   ts_prep(key = c(level_1, level_2), index = index, target = revenue)
#'   ts_model(ets(.ts),
#'            ets(log(.ts + 1)))
#'
#' your_mbl %>%
#'   ts_forecast(h = 12)
ts_forecast <- function(.data, h = 12) {

  if (!any(str_detect(colnames(.data), "model")))
    abort("Model columns not detected in the dataset")

  if (length(h) > 1) abort("h must be a single number")

  .data <- as_dt(.data)

  # Forecast time-series
  forecast_df <- .data %>%
    dt_mutate_across(
      c(dt_ends_with("model")),
      ~ map(.x, function(.y) forecast(.y, h = 12) %>%
                 as.data.table(keep.rownames = TRUE) %>%
                 dt_mutate(rn = str_c(rn, " 1")) %>%
                 dt_mutate(rn = myd(rn)) %>%
                 dt_rename(index = rn))
    ) %>%
    dt_rename_all(str_replace, "_model", "_forecast")

  # Extract forecasts
  forecast_df <- forecast_df %>%
    dt_pivot_longer(dt_ends_with("forecast"), names_to = "model", values_to = "forecast") %>%
    dt_mutate(model = str_replace(model, "_forecast", "")) %>%
    dt_unnest_legacy(forecast, keep = is.character)

  forecast_df %>%
    name_cleaner()
}
