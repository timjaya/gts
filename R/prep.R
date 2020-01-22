#' Convert tsibble to forecast ready object
#'
#' @param .data A data.frame or data.table
#'
#' @return A nested data frame
#' @export
#'
#' @examples
#' your_ts %>%
#'   ts_prep()
ts_prep <- function(.data,
                    key = NULL,
                    index = index,
                    target = NULL) {

  if (!is.data.frame(.data)) stop("dt_ must be a data.frame or data.table")

  .data <- as_dt(.data)

  index <- enexpr(index)
  key <- enexpr(key)
  target <- enexpr(target)

  if(is.null(target)) abort("target must be given")

  if (is.null(key)) {

    .data <- .data %>%
      dt_group_nest() %>%
      dt_rename(time_series = data)

  } else {
    groups <- tidydt:::vec_selector(.data, !!key)

    .data <- .data %>%
      dt_group_nest(!!!groups) %>%
      dt_rename(time_series = data)
  }

  .data %>%
    dt_mutate(time_series = dt_map(
      time_series,
      function(.x) .x %$%
        ts(!!target,
           start = c(year(min(!!index)), month(min(!!index))),
           end = c(year(max(!!index)), month(max(!!index))),
           frequency = 12
        )))
}
