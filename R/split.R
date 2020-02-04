#' Split data
#'
#' @description
#' Split data into a list of equal sized groups
#'
#' @param .data
#' @param times
#'
#' @export
#'
#' @examples
ts_split <- function(.data, times = 8) {
  .data %>%
    mutate(group_id = row_number() %% times) %>%
    group_split(group_id)
}
