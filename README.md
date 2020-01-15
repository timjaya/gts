
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gts v0.0.1

<!-- badges: start -->

[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
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
library(tidyverse)
library(forecast)
library(tsibble)
library(tsibbledata)
library(janitor)

# Create tsibble
aus_ts <- tsibbledata::aus_production %>%
  clean_names() %>%
  pivot_longer(-quarter, names_to = "product") %>%
  as_tsibble(index = quarter, key = product, value = value) %>%
  fill_gaps(value = 0)

aus_ts
#> # A tsibble: 1,308 x 3 [1Q]
#> # Key:       product [6]
#>    quarter product value
#>      <qtr> <chr>   <dbl>
#>  1 1956 Q1 beer      284
#>  2 1956 Q2 beer      213
#>  3 1956 Q3 beer      227
#>  4 1956 Q4 beer      308
#>  5 1957 Q1 beer      262
#>  6 1957 Q2 beer      228
#>  7 1957 Q3 beer      236
#>  8 1957 Q4 beer      320
#>  9 1958 Q1 beer      272
#> 10 1958 Q2 beer      233
#> # … with 1,298 more rows
```

You can now use this tsibble to use `gts`:

``` r
# Create a mable-like tibble
aus_mbl <- aus_ts %>%
  ts_prep() %>%
  ts_model(forecast::ets) %>%
  ts_model(forecast::ets, with_log = TRUE, mode = "MAM") %>%
  ts_model(forecast::auto.arima, with_log = TRUE)

# Create a fable-like tibble
aus_fbl <- aus_mbl %>%
  ts_forecast(h = 4)

aus_fbl
#> # A tibble: 72 x 8
#>    product model       index point_forecast lo_80 hi_80 lo_95 hi_95
#>    <chr>   <chr>       <qtr>          <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1 beer    arima_log 2010 Q3           408.  390.  427.  381.  437.
#>  2 beer    arima_log 2010 Q4           475.  454.  497.  443.  509.
#>  3 beer    arima_log 2011 Q1           413.  393.  433.  383.  444.
#>  4 beer    arima_log 2011 Q2           380.  361.  400.  352.  411.
#>  5 beer    ets       2010 Q3           405.  386.  423.  376.  433.
#>  6 beer    ets       2010 Q4           480.  458.  503.  445.  515.
#>  7 beer    ets       2011 Q1           417.  397.  438.  386.  448.
#>  8 beer    ets       2011 Q2           383.  364.  403.  353.  413.
#>  9 beer    ets_log   2010 Q3           407.  388.  426.  379.  436.
#> 10 beer    ets_log   2010 Q4           482.  459.  506.  447.  519.
#> # … with 62 more rows
```

You can also get in-sample accuracy:

``` r
aus_mbl %>%
  ts_accuracy()
#> # A tibble: 18 x 9
#>    product    model            ME     RMSE     MAE      MPE  MAPE  MASE     ACF1
#>    <chr>      <chr>         <dbl>    <dbl>   <dbl>    <dbl> <dbl> <dbl>    <dbl>
#>  1 beer       arima_l…  -0.000444   0.0342 2.69e-2 -0.00529 0.448 0.724  0.0194 
#>  2 beer       ets       -0.371     15.6    1.19e+1 -0.0713  2.84  0.765 -0.178  
#>  3 beer       ets_log    0.00148    0.0353 2.82e-2  0.0257  0.470 0.759 -0.156  
#>  4 bricks     arima_l…   0.00250    0.0506 3.77e-2  0.0423  0.630 0.434  0.0806 
#>  5 bricks     ets        0.946     21.6    1.58e+1  0.167   3.91  0.446  0.151  
#>  6 bricks     ets_log   -0.00149    0.0527 3.91e-2 -0.0262  0.655 0.451  0.123  
#>  7 cement     arima_l…   0.00157    0.0466 3.55e-2  0.0249  0.490 0.506  0.00539
#>  8 cement     ets        6.92      77.1    5.46e+1  0.328   3.64  0.535 -0.0205 
#>  9 cement     ets_log    0.00339    0.0467 3.61e-2  0.0435  0.498 0.515  0.00761
#> 10 electrici… arima_l…  -0.00237    0.0186 1.45e-2 -0.0234  0.144 0.287 -0.0419 
#> 11 electrici… ets        3.44     753.     4.74e+2  0.139   1.48  0.420 -0.0145 
#> 12 electrici… ets_log   -0.00236    0.0190 1.51e-2 -0.0232  0.149 0.298  0.0367 
#> 13 gas        arima_l…  -0.000205   0.0465 3.40e-2  0.0389  1.06  0.443  0.0112 
#> 14 gas        ets       -0.115      4.60   3.02e+0  0.199   4.08  0.542 -0.0131 
#> 15 gas        ets_log   -0.000741   0.0580 4.11e-2  0.0132  1.28  0.536  0.204  
#> 16 tobacco    arima_l…  -0.00865    0.0677 5.10e-2 -0.103   0.584 0.830 -0.0206 
#> 17 tobacco    ets      -43.9      427.     3.30e+2 -1.11    5.31  0.848  0.127  
#> 18 tobacco    ets_log   -0.00662    0.0696 5.26e-2 -0.0798  0.603 0.856  0.107
```

## Running in parallel

``` r
pacman::p_load(furrr)

model_fn <- function(.ts) {
  .ts %>%
    ts_model(forecast::ets) %>%
    ts_model(forecast::auto.arima)
}

plan(multiprocess)

tictoc::tic()

parallel_mbl <- aus_ts %>%
  ts_prep() %>%
  split(1:nrow(.) %% 6) %>%
  future_map_dfr(model_fn)

inv_gc()

parallel_fbl <- parallel_mbl %>%
  split(1:nrow(.) %% 6) %>%
  future_map_dfr(ts_forecast)

tictoc::toc()
#> 2.497 sec elapsed

future:::ClusterRegistry("stop")
```
