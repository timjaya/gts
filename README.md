
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gts v0.0.1

<!-- badges: start -->

[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
<!-- badges: end -->

The goal of gts is to provide a `fable`-like interface to the `forecast`
package.

## Installation

You can install the released version of gts from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("gts")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("mtfairbanks/gts")
```

## Example

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
  pivot_longer(-Quarter, names_to = "product") %>%
  clean_names() %>%
  as_tsibble(index = quarter, key = product, value = value) %>%
  fill_gaps(value = 0)

aus_ts
#> # A tsibble: 1,308 x 3 [1Q]
#> # Key:       product [6]
#>    quarter product value
#>      <qtr> <chr>   <dbl>
#>  1 1956 Q1 Beer      284
#>  2 1956 Q2 Beer      213
#>  3 1956 Q3 Beer      227
#>  4 1956 Q4 Beer      308
#>  5 1957 Q1 Beer      262
#>  6 1957 Q2 Beer      228
#>  7 1957 Q3 Beer      236
#>  8 1957 Q4 Beer      320
#>  9 1958 Q1 Beer      272
#> 10 1958 Q2 Beer      233
#> # … with 1,298 more rows
```

You can now use this object to use `gts`:

``` r
# Create a mable-like tibble
aus_mbl <- aus_ts %>%
  ts_prep() %>%
  ts_model(forecast::ets) %>%
  ts_model(forecast::ets, with_log = TRUE, mode = "MMM") %>%
  ts_model(forecast::auto.arima, with_log = TRUE)

# Create a fable-like tibble
aus_fbl <- aus_mbl %>%
  ts_forecast(h = 4)

aus_fbl
#> # A tibble: 216 x 8
#>    product model   index point_forecast  lo_80  hi_80  lo_95  hi_95
#>    <chr>   <chr>   <qtr>          <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
#>  1 Beer    ets   2010 Q3           405. 386.   423.   376.   433.  
#>  2 Beer    ets   2010 Q4           480. 458.   503.   445.   515.  
#>  3 Beer    ets   2011 Q1           417. 397.   438.   386.   448.  
#>  4 Beer    ets   2011 Q2           383. 364.   403.   353.   413.  
#>  5 Beer    ets   2010 Q3           406.   5.96   6.05   5.94   6.08
#>  6 Beer    ets   2010 Q4           481.   6.13   6.22   6.10   6.25
#>  7 Beer    ets   2011 Q1           418.   5.99   6.08   5.96   6.11
#>  8 Beer    ets   2011 Q2           384.   5.90   6.00   5.87   6.02
#>  9 Beer    ets   2010 Q3           408.   5.97   6.06   5.94   6.08
#> 10 Beer    ets   2010 Q4           475.   6.12   6.21   6.09   6.23
#> # … with 206 more rows
```

You can also get in-sample accuracy:

``` r
aus_mbl %>%
  ts_accuracy()
#> # A tibble: 18 x 9
#>    product    model            ME     RMSE     MAE      MPE  MAPE  MASE     ACF1
#>    <chr>      <chr>         <dbl>    <dbl>   <dbl>    <dbl> <dbl> <dbl>    <dbl>
#>  1 Beer       ets       -0.371     15.6    1.19e+1 -0.0713  2.84  0.765 -0.178  
#>  2 Beer       ets_log    0.00113    0.0354 2.83e-2  0.0199  0.472 0.760 -0.163  
#>  3 Beer       arima_l…  -0.000445   0.0343 2.70e-2 -0.00529 0.449 0.724  0.0195 
#>  4 Bricks     ets        0.946     21.6    1.58e+1  0.167   3.91  0.446  0.151  
#>  5 Bricks     ets_log   -0.000932   0.0521 3.88e-2 -0.0207  0.649 0.446  0.114  
#>  6 Bricks     arima_l…   0.00249    0.0508 3.78e-2  0.0423  0.632 0.434  0.0804 
#>  7 Cement     ets        6.92      77.1    5.46e+1  0.328   3.64  0.535 -0.0205 
#>  8 Cement     ets_log    0.00266    0.0466 3.62e-2  0.0335  0.500 0.517 -0.0550 
#>  9 Cement     arima_l…   0.00157    0.0467 3.55e-2  0.0249  0.490 0.506  0.00533
#> 10 Electrici… ets        3.44     753.     4.74e+2  0.139   1.48  0.420 -0.0145 
#> 11 Electrici… ets_log   -0.00267    0.0191 1.52e-2 -0.0261  0.150 0.300  0.0975 
#> 12 Electrici… arima_l…  -0.00237    0.0186 1.45e-2 -0.0234  0.144 0.287 -0.0419 
#> 13 Gas        ets       -0.115      4.60   3.02e+0  0.199   4.08  0.542 -0.0131 
#> 14 Gas        ets_log    0.00416    0.0635 4.38e-2  0.143   1.44  0.548  0.185  
#> 15 Gas        arima_l…  -0.000245   0.0506 3.63e-2  0.0414  1.19  0.454  0.0114 
#> 16 Tobacco    ets      -43.9      427.     3.30e+2 -1.11    5.31  0.848  0.127  
#> 17 Tobacco    ets_log   -0.00665    0.0696 5.26e-2 -0.0802  0.604 0.856  0.107  
#> 18 Tobacco    arima_l…  -0.00865    0.0678 5.10e-2 -0.103   0.584 0.830 -0.0206
```

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub\!
