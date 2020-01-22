
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
           ets(log(.ts + 1)),
           auto.arima(.ts))

aus_mbl
#>                        animal                        state ets_model
#> 1: Bulls, bullocks and steers Australian Capital Territory     <ets>
#> 2: Bulls, bullocks and steers              New South Wales     <ets>
#> 3: Bulls, bullocks and steers           Northern Territory     <ets>
#> 4: Bulls, bullocks and steers                   Queensland     <ets>
#> 5: Bulls, bullocks and steers              South Australia     <ets>
#>    ets_log1_model      arima_model
#> 1:          <ets> <forecast_ARIMA>
#> 2:          <ets> <forecast_ARIMA>
#> 3:          <ets> <forecast_ARIMA>
#> 4:          <ets> <forecast_ARIMA>
#> 5:          <ets> <forecast_ARIMA>
```

From the mable we can create a fable-like data.table

``` r
aus_fbl <- aus_mbl %>%
  ts_forecast(h = 12)

aus_fbl
#>      model      index point_forecast      lo_80      hi_80      lo_95
#>   1:   ets 2019-01-01  3.078689e-115  -500.3675   500.3675  -765.2461
#>   2:   ets 2019-02-01  3.078689e-115  -580.9115   580.9115  -888.4275
#>   3:   ets 2019-03-01  3.078689e-115  -651.5740   651.5740  -996.4965
#>   4:   ets 2019-04-01  3.078689e-115  -715.2896   715.2896 -1093.9411
#>   5:   ets 2019-05-01  3.078689e-115  -773.7763   773.7763 -1183.3888
#>  ---                                                                 
#> 176: arima 2019-08-01   7.148330e+03 -1070.1868 15366.8465 -5420.8067
#> 177: arima 2019-09-01   6.577521e+03 -2101.5672 15256.6092 -6695.9990
#> 178: arima 2019-10-01   7.071437e+03 -2044.8625 16187.7356 -6870.7397
#> 179: arima 2019-11-01   7.770096e+03 -1763.4258 17303.6187 -6810.1677
#> 180: arima 2019-12-01   6.812286e+03 -3120.9357 16745.5080 -8379.2657
#>           hi_95
#>   1:   765.2461
#>   2:   888.4275
#>   3:   996.4965
#>   4:  1093.9411
#>   5:  1183.3888
#>  ---           
#> 176: 19717.4664
#> 177: 19851.0410
#> 178: 21013.6129
#> 179: 22350.3606
#> 180: 22003.8380
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
#> 11:    arima -1.109694e+01 3.773846e+02 1.734394e+02         -Inf        Inf
#> 12:    arima -1.242431e+02 8.680131e+03 6.830231e+03 -1.013777047  8.6640160
#> 13:    arima  1.757011e+01 1.090609e+03 6.645116e+02          NaN        Inf
#> 14:    arima  2.658329e+01 1.490383e+04 1.171253e+04 -1.150596087  8.6560519
#> 15:    arima -2.844659e+01 2.951283e+03 2.290741e+03 -2.252663183 13.8456631
#>          MASE         ACF1
#>  1: 0.5647694  0.094640232
#>  2: 0.6302549  0.168202579
#>  3: 1.0421858  0.468540115
#>  4: 0.7153801  0.169026217
#>  5: 0.6602600  0.048742434
#>  6: 0.4581168  0.089644134
#>  7: 0.6326775  0.009026354
#>  8: 0.8977181  0.012823318
#>  9: 0.7137565  0.112468869
#> 10: 0.6866878  0.181332299
#> 11: 0.5781314  0.012014218
#> 12: 0.6690378 -0.011668038
#> 13: 0.8580182 -0.004675357
#> 14: 0.6772605 -0.003615451
#> 15: 0.6976449 -0.044117964
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
  split(1:nrow(.) %% 6) %>%
  future_map_dfr(model_fn)

parallel_fbl <- parallel_mbl %>%
  split(1:nrow(.) %% 6) %>%
  future_map_dfr(ts_forecast)

future:::ClusterRegistry("stop")
```
