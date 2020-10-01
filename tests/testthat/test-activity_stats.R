
# rm(list = ls()); library(testthat); library(arctools)

require(data.table)
require(lubridate)
require(dplyr)


## CONTEXT (without exclude or include) ----------------------------------------

context("Testing activity_stats()")

out_activity_stats <- lapply(extdata_fnames, function(extdata_fname_i) {
  dat_i <-
    fread(system.file("extdata", extdata_fname_i, package = "arctools")) %>%
    as.data.frame()
  acc     <- dat_i$vectormagnitude
  acc_ts  <- ymd_hms(dat_i$timestamp)
  out <- activity_stats(acc, acc_ts)
  return(out)
})

out_all_steps <- lapply(extdata_fnames, function(extdata_fname_i) {
  dat_i <-
    fread(system.file("extdata", extdata_fname_i, package = "arctools")) %>%
    as.data.frame()
  acc    <- dat_i$vectormagnitude
  acc_ts <- ymd_hms(dat_i$timestamp)
  ## Get acc data vector in "midnight_to_midnight" format
  acc <- midnight_to_midnight(acc, acc_ts)
  ## Get wear/non-wear flag
  wear_flag <- get_wear_flag(acc)
  ## Get valid/non-valid day flag
  valid_day_flag <- get_valid_day_flag(wear_flag)
  ## Impute missing data in acc data vector
  acc <- impute_missing_data(acc, wear_flag, valid_day_flag)
  ## Summarize PA
  out <- summarize_PA(acc, acc_ts, wear_flag, valid_day_flag)
  return(out)
})


test_that_desc <- paste0(
  "Compare the wrapper out_activity_stats() gives same results as step by step procedure")
test_that(test_that_desc, {
  for (i in 1:length(out_activity_stats)){ # i <- 4
    out1 <- out_activity_stats[[i]]
    out2 <- out_all_steps[[i]]
    expect_equal(unlist(out1), unlist(out2))
  }
})


## -----------------------------------------------------------------------------
## -----------------------------------------------------------------------------
## -----------------------------------------------------------------------------

context("Testing summarize_PA() for computing summaries in subsets per days of the weeks")

set.seed(1)
n <- 1440 * 7
acc <- round(10000 * runif(n = n))
acc_ts <- seq(from = as.POSIXct("2020-09-21 00:00:00.00", tz = "UTC"), by = 60, length.out = n)

test_that("Error ocurrs when subset_weekdays arg is misspecified", {
  expect_error({
    as_out <- activity_stats(acc, acc_ts, subset_weekdays = c(0))
  })
})

test_that("The value of activity_stats remains unchanged", {

  out_act <- unlist(activity_stats(acc, acc_ts, subset_weekdays = c(6,7)))
  out_exp <- c(n_days = 7, n_valid_days = 7, wear_time_on_valid_days = 1440,
               tac_weekdays67only = 2058690.28571429, tlac_weekdays67only = 3374.74392287859,
               ltac_weekdays67only = 14.5375805549358, astp_weekdays67only = 0.181624840493407,
               satp_weekdays67only = 0.805293005671077, time_spent_active_weekdays67only = 335.857142857143,
               time_spent_nonactive_weekdays67only = 75.5714285714286, no_of_active_bouts_weekdays67only = 61,
               no_of_nonactive_bouts_weekdays67only = 60.8571428571429, mean_active_bout_weekdays67only = 5.50585480093677,
               mean_nonactive_bout_weekdays67only = 1.24178403755869)
  expect_equal(out_act, out_exp)

  out_act <- unlist(activity_stats(acc, acc_ts, subset_weekdays = c(1:5)))
  out_exp <- c(n_days = 7, n_valid_days = 7, wear_time_on_valid_days = 1440,
               tac_weekdays12345only = 5139302.85714286, tlac_weekdays12345only = 8438.35927660827,
               ltac_weekdays12345only = 15.4524279973266, astp_weekdays12345only = 0.189601921757035,
               satp_weekdays12345only = 0.803935860058309, time_spent_active_weekdays12345only = 832.571428571429,
               time_spent_nonactive_weekdays12345only = 196, no_of_active_bouts_weekdays12345only = 157.857142857143,
               no_of_nonactive_bouts_weekdays12345only = 157.571428571429, mean_active_bout_weekdays12345only = 5.27420814479638,
               mean_nonactive_bout_weekdays12345only = 1.24388032638259)
  expect_equal(out_act, out_exp)
})
