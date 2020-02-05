#' Convert tsibble to forecast ready object
#'
#' @param .data A data.frame or data.table
#'
#' @export
#'
#' @examples
#' your_df %>%
#'   ts_prep(key = c(level_1, level_2), index = index, target = revenue)
ts_prep <- function(.data,
                    key = NULL,
                    index = index,
                    target = NULL) {

  if (!is.data.frame(.data)) stop(".data must be a data.frame or data.table")
  if (!data.table::is.data.table(.data)) .data <- data.table::as.data.table(.data)

  index <- enexpr(index)
  key <- enexpr(key)
  target <- enexpr(target)

  if(is.null(target)) abort("target must be given")

  if (is.null(key)) {

    .data <- .data %>%
      ts_group_nest() %>%
      as_tibble()

  } else {
    groups <- vec_selector(.data, !!key)

    .data <- .data %>%
      ts_group_nest(!!!groups) %>%
      as_tibble()

  }

  # NOTE: is.numeric might be bad
  # Have different behavior for column type

  if (is.numeric(index_col)) {
    print("NOTE: Index column is detected as Integer.")

    .data %>%
      mutate(
        time_series = map(time_series, as_tsibble, index = !!index)
      )

  }

  else if (is.Date(index_col)) {
    print("NOTE: Index column is detected as Date.\n")
    .data %>%
      mutate(
        time_series = map(
          time_series,
          function(.x) ts('$'(.x, !!target),
                          start = c(year(min('$'(.x, !!index))), month(min('$'(.x, !!index)))),
                          end = c(year(max('$'(.x, !!index))), month(max('$'(.x, !!index)))),
                          frequency = 12) %>%
            as_tsibble() %>%
            rename(!!target := value)
        ))
  }

  else abort("Index format not recognizable. Make sure its either in Integer (period) or Date format.")

}
