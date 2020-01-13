#' Convert tsibble to forecast ready object
#'
#' @param .ts A tsibble
#'
#' @return A nested data frame
#' @export
#'
#' @examples
#' your_ts %>%
#'   ts_prep()
ts_prep <- function(.ts) {

  if(!is_tsibble(.ts)) abort(".ts must be a tsibble")

  if (length(key_vars(.ts)) == 0) {
    .ts %>%
      nest() %>%
      mutate(ts = map(data, as.ts)) %>%
      select(-data)
  } else {
    .ts %>%
      group_by_key() %>%
      nest() %>%
      mutate(ts = map(data, as.ts)) %>%
      select(-data)
  }
}
