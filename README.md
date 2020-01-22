
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gts v0.0.1

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

The goal of gts is to provide a `fable`-like interface to the `forecast`
package.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("markfairbanks/gts")
```

## Functions

`gts` has 4 core functions:

  - `ts_prep()`: Convert a tsibble to a `gts` ready dataset
  - `ts_model()`: Apply a `forecast` function
  - `ts_forecast()`: Create forecasts for all trained models
  - `ts_accuracy()`: Extract in-sample accuracy for all trained models

## Examples

We start by creating a tsibble object:

``` r
library(gts)

# # Create tsibble
# aus_ts <- tsibbledata::aus_production %>%
#   clean_names() %>%
#   pivot_longer(-quarter, names_to = "product") %>%
#   as_tsibble(index = quarter, key = product, value = value) %>%
#   fill_gaps(value = 0)
# 
# aus_ts
```

You can now use this tsibble to use `gts`:

``` r
# Create a mable-like tibble
# aus_mbl <- aus_ts %>%
#   ts_prep() %>%
#   ts_model(forecast::ets) %>%
#   ts_model(forecast::ets, with_log = TRUE, model = "MAM") %>%
#   ts_model(forecast::auto.arima, with_log = TRUE)
# 
# # Create a fable-like tibble
# aus_fbl <- aus_mbl %>%
#   ts_forecast(h = 4)
# 
# aus_fbl
```

You can also get in-sample accuracy:

``` r
# aus_mbl %>%
#   ts_accuracy()
```

## Running in parallel

<!-- ```{r warning=FALSE} -->

<!-- pacman::p_load(furrr) -->

<!-- model_fn <- function(.ts) { -->

<!--   .ts %>% -->

<!--     ts_model(forecast::ets) %>% -->

<!--     ts_model(forecast::auto.arima) -->

<!-- } -->

<!-- plan(multiprocess) -->

<!-- tictoc::tic() -->

<!-- parallel_mbl <- aus_ts %>% -->

<!--   ts_prep() %>% -->

<!--   split(1:nrow(.) %% 6) %>% -->

<!--   future_map_dfr(model_fn) -->

<!-- inv_gc() -->

<!-- parallel_fbl <- parallel_mbl %>% -->

<!--   split(1:nrow(.) %% 6) %>% -->

<!--   future_map_dfr(ts_forecast) -->

<!-- tictoc::toc() -->

<!-- future:::ClusterRegistry("stop") -->

<!-- ``` -->
