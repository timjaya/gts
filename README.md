
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gts v0.0.1

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

The goal of `gts` is to speed up the functionality provided by `fable`.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("markfairbanks/gts")
```

## Functions

`gts` has 3 core functions:

  - `ts_prep()`: Convert a data frame to a `gts` ready dataset
  - `ts_split()`: Split your dataset to quickly enable parallel
    processing
  - `ts_unnest_fable()`: Unnest a fable column

## Examples

Starting with some example data:

``` r
library(gts)
library(fpp3)
library(tidyverse)

aus_df <- tsibbledata::aus_livestock %>%
  rename_all(janitor::make_clean_names) %>%
  filter(state == "Australian Capital Territory") %>%
  mutate(month = as_date(month))

head(aus_df)
#> # A tsibble: 6 x 4 [1D]
#> # Key:       animal, state [1]
#>   month      animal                     state                        count
#>   <date>     <fct>                      <fct>                        <dbl>
#> 1 1976-07-01 Bulls, bullocks and steers Australian Capital Territory  2300
#> 2 1976-08-01 Bulls, bullocks and steers Australian Capital Territory  2100
#> 3 1976-09-01 Bulls, bullocks and steers Australian Capital Territory  2100
#> 4 1976-10-01 Bulls, bullocks and steers Australian Capital Territory  1900
#> 5 1976-11-01 Bulls, bullocks and steers Australian Capital Territory  2100
#> 6 1976-12-01 Bulls, bullocks and steers Australian Capital Territory  1800
```

You can then use this to prep your data and create models

``` r
aus_ts <- aus_df %>%
  ts_prep(key = c(animal, state), index = month, target = count) %>%
  mutate(mable = map(time_series, model,
                     ets = ETS(count)))
  
aus_ts
#> # A tibble: 6 x 4
#>   animal                 state                   time_series       mable        
#>   <fct>                  <fct>                   <list>            <list>       
#> 1 Bulls, bullocks and s… Australian Capital Ter… <tsibble [510 × … <tibble [1 ×…
#> 2 Calves                 Australian Capital Ter… <tsibble [558 × … <tibble [1 ×…
#> 3 Cattle (excl. calves)  Australian Capital Ter… <tsibble [558 × … <tibble [1 ×…
#> 4 Lambs                  Australian Capital Ter… <tsibble [558 × … <tibble [1 ×…
#> 5 Pigs                   Australian Capital Ter… <tsibble [558 × … <tibble [1 ×…
#> 6 Sheep                  Australian Capital Ter… <tsibble [558 × … <tibble [1 ×…
```

You can create forecasts from here, or get model accuracy.

``` r
aus_ts <- aus_ts %>%
  mutate(fable = map(mable, forecast, h = 1),
         accuracy = map(mable, accuracy))

aus_ts
#> # A tibble: 6 x 6
#>   animal          state           time_series    mable     fable     accuracy   
#>   <fct>           <fct>           <list>         <list>    <list>    <list>     
#> 1 Bulls, bullock… Australian Cap… <tsibble [510… <tibble … <fable [… <tibble [1…
#> 2 Calves          Australian Cap… <tsibble [558… <tibble … <fable [… <tibble [1…
#> 3 Cattle (excl. … Australian Cap… <tsibble [558… <tibble … <fable [… <tibble [1…
#> 4 Lambs           Australian Cap… <tsibble [558… <tibble … <fable [… <tibble [1…
#> 5 Pigs            Australian Cap… <tsibble [558… <tibble … <fable [… <tibble [1…
#> 6 Sheep           Australian Cap… <tsibble [558… <tibble … <fable [… <tibble [1…
```

You can unnest the fable as follows:

``` r
aus_ts %>%
  ts_unnest_fable(fable)
#> # A tibble: 6 x 6
#>   animal               state                 .model index           count    .sd
#>   <fct>                <fct>                 <chr>  <date>          <dbl>  <dbl>
#> 1 Bulls, bullocks and… Australian Capital T… ets    2019-01-01  3.08e-115  390. 
#> 2 Calves               Australian Capital T… ets    2019-01-01  8.78e+  0   81.9
#> 3 Cattle (excl. calve… Australian Capital T… ets    2019-01-01  9.84e+  1  408. 
#> 4 Lambs                Australian Capital T… ets    2019-01-01  1.19e+  2 3488. 
#> 5 Pigs                 Australian Capital T… ets    2019-01-01 -3.35e+  2  605. 
#> 6 Sheep                Australian Capital T… ets    2019-01-01  1.91e-119 1691.
```

## Running in parallel

``` r
pacman::p_load(furrr)

model_fn <- function(.data) {
  .data %>%
    mutate(mable = map(time_series, model,
                       ets = ETS(count)),
           fable = map(mable, forecast, h = 1),
           accuracy = map(mable, accuracy))
}

plan(multiprocess)

parallel_ts <- aus_df %>%
  ts_prep(key = c(animal, state), index = month, target = count) %>%
  ts_split(6) %>%
  future_map_dfr(model_fn)

future:::ClusterRegistry("stop")
```
