#' Get in-sample accuracy of all models
#'
#' @description
#' Get in-sample accuracy of all models from a `gts` mable
#'
#' @param .ts A `gts` mable
#'
#' @return A tibble
#' @export
#'
#' @examples
#' your_mbl <- your_ts %>%
#'   ts_prep() %>%
#'   ts_model(forecast::auto.arima) %>%
#'   ts_model(forecast::ets, with_log = TRUE)
#'
#' your_mbl %>%
#'   ts_accuracy()
ts_accuracy <- function(.ts) {

  if (!any(str_detect(colnames(.ts), "model")))
    abort("Model columns not detected in the dataset")

  accuracy_df <- .ts %>%
    mutate_at(vars(ends_with("model")),
              list(accuracy = ~.x %>%
                     map(~.x %>%
                           accuracy() %>%
                           as_tibble()))) %>%
    rename_all(str_replace, "_model_", "_")

  model_count <- colnames(.ts) %>%
    str_detect("model") %>%
    sum()

  if (model_count == 1) {
    accuracy_df <- accuracy_df %>%
      select(group_cols(), ends_with("model"), ends_with("accuracy")) %>%
      mutate_at(vars(ends_with("model")), ~1) %>%
      pivot_longer(ends_with("model"), names_to = "model") %>%
      select(-value) %>%
      mutate(model = str_replace(model, "_model", "")) %>%
      group_by_at(vars(-ends_with("accuracy"))) %>%
      select(group_cols(), everything()) %>%
      unnest(accuracy) %>%
      ungroup()
  } else {
    accuracy_df <- accuracy_df %>%
      select(group_cols(), ends_with("accuracy")) %>%
      pivot_longer(ends_with("accuracy"), names_to = "model", values_to = "accuracy") %>%
      mutate(model = str_replace(model, "_accuracy", "")) %>%
      group_by_at(vars(-ends_with("accuracy"))) %>%
      select(group_cols(), everything()) %>%
      unnest(accuracy) %>%
      ungroup()
  }
  accuracy_df
}
