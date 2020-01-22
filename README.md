
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

  - `ts_prep()`: Convert a data frame to a `gts` ready dataset
  - `ts_model()`: Apply a `forecast` function
  - `ts_forecast()`: Create forecasts for all trained models
  - `ts_accuracy()`: Extract in-sample accuracy for all trained models

## Examples

Starting with some example data:

``` r
library(gts)
library(janitor)
library(tsibbledata)

aus_df <- tsibbledata::aus_livestock %>%
  janitor::clean_names() %>%
  dt_arrange(animal, state) %>%
  dt_mutate(group_id = .GRP, by = list(animal, state)) %>%
  dt_filter(group_id <= 5) %>%
  dt_mutate(month = as_date(month))

head(aus_df)
#>         month                     animal                        state count
#> 1: 1976-07-01 Bulls, bullocks and steers Australian Capital Territory  2300
#> 2: 1976-08-01 Bulls, bullocks and steers Australian Capital Territory  2100
#> 3: 1976-09-01 Bulls, bullocks and steers Australian Capital Territory  2100
#> 4: 1976-10-01 Bulls, bullocks and steers Australian Capital Territory  1900
#> 5: 1976-11-01 Bulls, bullocks and steers Australian Capital Territory  2100
#> 6: 1976-12-01 Bulls, bullocks and steers Australian Capital Territory  1800
#>    group_id
#> 1:        1
#> 2:        1
#> 3:        1
#> 4:        1
#> 5:        1
#> 6:        1
```

We can now make a mable-like data.table. Note that you must use `.ts`
when calling `ts_model()`.

``` r
aus_mbl <- aus_df %>%
  ts_prep(key = c(animal, state), index = month, target = count) %>%
  ts_model(ets(.ts),
           ets(log(.ts + 1)))

aus_mbl
#>                        animal                        state ets_model
#> 1: Bulls, bullocks and steers Australian Capital Territory     <ets>
#> 2: Bulls, bullocks and steers              New South Wales     <ets>
#> 3: Bulls, bullocks and steers           Northern Territory     <ets>
#> 4: Bulls, bullocks and steers                   Queensland     <ets>
#> 5: Bulls, bullocks and steers              South Australia     <ets>
#>    ets_log1_model
#> 1:          <ets>
#> 2:          <ets>
#> 3:          <ets>
#> 4:          <ets>
#> 5:          <ets>
```

From the mable we can create a fable-like data.table:

``` r
aus_fbl <- aus_mbl %>%
  ts_forecast(h = 12)

aus_fbl
#>         model      index point_forecast       lo_80      hi_80        lo_95
#>   1:      ets 2019-01-01  3.078689e-115 -500.367538 500.367538  -765.246112
#>   2:      ets 2019-02-01  3.078689e-115 -580.911525 580.911525  -888.427511
#>   3:      ets 2019-03-01  3.078689e-115 -651.574039 651.574039  -996.496500
#>   4:      ets 2019-04-01  3.078689e-115 -715.289630 715.289630 -1093.941088
#>   5:      ets 2019-05-01  3.078689e-115 -773.776313 773.776313 -1183.388751
#>  ---                                                                       
#> 116: ets_log1 2019-08-01   9.311334e+00    9.007284   9.615385     8.846329
#> 117: ets_log1 2019-09-01   9.259341e+00    8.945718   9.572963     8.779697
#> 118: ets_log1 2019-10-01   9.288561e+00    8.965651   9.611472     8.794712
#> 119: ets_log1 2019-11-01   9.396077e+00    9.064138   9.728016     8.888420
#> 120: ets_log1 2019-12-01   9.281685e+00    8.924687   9.638683     8.735703
#>            hi_95
#>   1:  765.246112
#>   2:  888.427511
#>   3:  996.496500
#>   4: 1093.941088
#>   5: 1183.388751
#>  ---            
#> 116:    9.776339
#> 117:    9.738985
#> 118:    9.782411
#> 119:    9.903734
#> 120:    9.827666
```

You can also get in-sample accuracy from the mable:

``` r
aus_mbl %>%
  ts_accuracy()
#>        model            ME         RMSE          MAE          MPE       MAPE
#>  1:      ets -7.347381e+00 3.896725e+02 1.694308e+02         -Inf        Inf
#>  2:      ets -3.153332e+02 8.243792e+03 6.434295e+03 -1.202820195  8.1505567
#>  3:      ets -6.002152e+00 1.391448e+03 8.071443e+02          NaN        Inf
#>  4:      ets  2.419641e+02 1.584875e+04 1.237177e+04 -0.875072245  9.2899780
#>  5:      ets -4.973190e+01 2.792709e+03 2.167986e+03 -2.620226761 13.1944073
#>  6: ets_log1 -2.192146e-02 8.758538e-01 1.891442e-01         -Inf        Inf
#>  7: ets_log1 -2.767972e-03 1.006420e-01 8.058077e-02 -0.030315742  0.7155280
#>  8: ets_log1 -1.755997e-02 5.805383e-01 3.492595e-01          NaN        Inf
#>  9: ets_log1  8.418707e-04 1.181697e-01 9.093431e-02  0.003365252  0.7722429
#> 10: ets_log1 -4.185539e-03 1.738852e-01 1.317495e-01 -0.066667604  1.3607594
#>          MASE        ACF1
#>  1: 0.5647694 0.094640232
#>  2: 0.6302549 0.168202579
#>  3: 1.0421858 0.468540115
#>  4: 0.7153801 0.169026217
#>  5: 0.6602600 0.048742434
#>  6: 0.4581168 0.089644134
#>  7: 0.6326775 0.009026354
#>  8: 0.8977181 0.012823318
#>  9: 0.7137565 0.112468869
#> 10: 0.6866878 0.181332299
```

## Running in parallel

``` r
pacman::p_load(furrr)

model_fn <- function(.data) {
  .data %>%
    ts_model(ets(.ts),
             ets(log(.ts + 1)))
}

plan(multiprocess)

parallel_mbl <- aus_df %>%
  ts_prep(key = c(animal, state), index = month, target = count) %>%
  dt_mutate(group_id = 1:.N %% 6) %>%
  split(by = "group_id") %>% # Note: This version of split() uses data.table in the background
  future_map_dfr(model_fn)

parallel_fbl <- parallel_mbl %>%
  as_dt() %>%
  dt_mutate(group_id = 1:.N %% 6) %>%
  split(by = "group_id") %>% # Note: This version of split() uses data.table in the background
  future_map_dfr(ts_forecast)

future:::ClusterRegistry("stop")
```
