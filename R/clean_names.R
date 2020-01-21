name_cleaner <- function(dat, case = c(
  "snake", "lower_camel", "upper_camel", "screaming_snake",
  "lower_upper", "upper_lower", "all_caps", "small_camel",
  "big_camel", "old_janitor", "parsed", "mixed", "none"
)) {
  if(!is.data.frame(dat)){
    stop( "clean_names() must be called on a data.frame.  Consider janitor::make_clean_names() for other cases of manipulating vectors of names.")
  }
  stats::setNames(dat, old_make_clean_names(names(dat), case = case))
}

old_make_clean_names <- function(string) {

  # Takes a data.frame, returns the same data frame with cleaned names
  old_names <- string
  new_names <- old_names %>%
    gsub("'", "", .) %>% # remove quotation marks
    gsub("\"", "", .) %>% # remove quotation marks
    gsub("%", "percent", .) %>%
    gsub("^[ ]+", "", .) %>%
    make.names(.) %>%
    gsub("[.]+", "_", .) %>% # convert 1+ periods to single _
    gsub("[_]+", "_", .) %>% # fix rare cases of multiple consecutive underscores
    tolower(.) %>%
    gsub("_$", "", .) # remove string-final underscores

  # Handle duplicated names - they mess up dplyr pipelines
  # This appends the column number to repeated instances of duplicate variable names
  dupe_count <- vapply(seq_along(new_names), function(i) {
    sum(new_names[i] == new_names[1:i])
  }, integer(1))

  new_names[dupe_count > 1] <- paste(
    new_names[dupe_count > 1],
    dupe_count[dupe_count > 1],
    sep = "_"
  )
  new_names
}
