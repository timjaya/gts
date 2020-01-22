#' Get in-sample accuracy of all models
#'
#' @description
#' Get in-sample accuracy of all models from a `gts` mable
#'
#' @param .ts A `gts` mable
#'
#' @return A data.table
#' @export
#'
#' @examples
#' your_mbl <- your_df %>%
#'   ts_prep(key = c(level_1, level_2), index = index, target = revenue)
#'   ts_model(ets(.ts),
#'            ets(log(.ts + 1)))
#'
#' your_mbl %>%
#'   ts_accuracy()
ts_accuracy <- function(.data) {

  if (!any(str_detect(colnames(.data), "model")))
    abort("Model columns not detected in the dataset")

  accuracy_df <- .data %>%
    dt_mutate_across(
      c(dt_ends_with("model")),
      ~ dt_map(.x, function(.y) .y %>%
                 accuracy() %>%
                 as.data.table())) %>%
    dt_rename_all(str_replace, "_model", "_accuracy")

  accuracy_df <- accuracy_df %>%
    dt_pivot_longer(dt_ends_with("accuracy"), names_to = "model", values_to = "accuracy") %>%
    dt_mutate(model = str_replace(model, "_forecast", "")) %>%
    dt_unnest_legacy(forecast, keep = is.character)

  accuracy_df
}
