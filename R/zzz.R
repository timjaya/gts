.onLoad <- function(libname, pkgname) {
  requireNamespace(forecast)
  requireNamespace(lubridate)
  requireNamespace(stringr)
  requireNamespace(purrr)
  invisible()
}
