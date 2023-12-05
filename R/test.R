library(dplyr)
library(tidyr)
library(vdiffr)
library(testthat)
# source("R/ct-util.R")


# show schema tables
dbGetQuery(con, "SHOW TABLES;")

# get unique phase levels from studies table
study_phases_u <- STUDIES |> dplyr::select(phase) |> dplyr::distinct() |> collect()
studies_df <- STUDIES |> head(30000) |> collect()
conditions_df <- CONDITIONS |> head(5000) |> collect()

# call plot function
plot_phase_histogram(studies_df = studies_df, phase_labels = study_phases_u)

# cumulative studies
d = STUDIES |>
  query_kwds("pembrolizumab", "brief_title") |>
  dplyr::select(start_date, completion_date) |>
  collect() |>
  get_concurrent_studies() |>
  ggplot2::ggplot(aes(x = date, y = count)) +
    ggplot2::geom_line() +
    ggplot2::xlab("Date") +
    ggplot2::ylab("Count")


############################
#### TestThat Functions ####
############################

testthat::test_that("get concurrent studies", {
  # Call the function with the test data frame
  sampled_studies_df <- studies_df |>
    dplyr::select(start_date, completion_date)
  result <- get_concurrent_studies(studies_df=sampled_studies_df)

  # Check that the result has the correct columns
  expect_identical(names(result), c("date", "count"))

  # Check that the result has the correct number of rows
  full_dates <- na.omit(c(studies_df$start_date, studies_df$completion_date))
  expect_equal(nrow(result), length(unique(full_dates)))

  # Check that the count column contains only non-negative numbers
  expect_true(all(result$count >= 0))
})


testthat::test_that("plot concurrent studies", {
  # Define a simple data frame of studies
  studies_df <- data.frame(
    start_date = as.Date(c('2020-01-01', '2020-02-01', '2020-03-01')),
    completion_date = as.Date(c('2020-12-31', '2020-11-30', '2020-10-31')))

  # Call the function with the test data frame
  result <- plot_concurrent_studies(studies_df=studies_df)

  # Check that the "concurrent_df" tibble has the correct columns
  expect_identical(names(result$concurrent_df), c("date", "count"))

  # Check that the "concurrent_line_plot" element is a ggplot object
  expect_true(is.ggplot(result$concurrent_line_plot))

  vdiffr::expect_doppelganger(
    title="plot-concurrent-studies-1",
    result$concurrent_line_plot
  )

})


testthat::test_that("get_study_conditions correctly joins studies and conditions data", {
  result <- get_study_conditions(studies_df=studies_df, conditions_df=conditions_df) |>
    head(4) |>
    select(nct_id, condition_name, source)

  expected <- data.frame(
    nct_id = c("NCT03208920", "NCT03937466", "NCT03194958", "NCT01604512"),
    condition_name = c("PAD", "Menopause", "Smoking, Pipe", "Brain Cancer"),
    source = c("University of California, San Francisco", "Wake Forest University Health Sciences",
               "Washington University School of Medicine", "Memorial Sloan Kettering Cancer Center"))

  expect_identical(result, tibble(expected))

})


testthat::test_that("summarize_study_conditions", {
  study_conditions_df <- get_study_conditions(studies_df=studies_df, conditions_df=conditions_df)

  top_n <- 2
  result <- summarize_study_conditions(study_conditions_df, top_n = top_n, lump_fct = FALSE)

  # Check that the result has the correct number of rows
  expect_equal(nrow(result), top_n)

  # Check that the "n" column contains only non-negatives
  expect_true(all(result$n >= 0))

  # Check that result output matches expected
  expected <- data.frame(
    condition_name = factor(c("HIV", "Obesity"), levels = c("Obesity", "HIV")),
    n = as.integer(c(2, 2)))

})


testthat::test_that("plot study conditions histogram", {
  result <- plot_study_conditions_histogram(studies_df=studies_df, top_n = 3)

  # Check that the list has the correct names
  expect_identical(names(result), c("summ_df", "study_cond_plot"))

  # Check that the "summ_df" data frame has the correct columns
  expect_identical(names(result$summ_df), c("condition_name", "n"))

  # Check that the "summ_df" data frame has the correct columns
  expect_identical(levels(result$summ_df$condition_name), c("Healthy", "Breast Cancer", "Obesity"))

  # Check that the "study_cond_plot" element is a ggplot object
  expect_true(ggplot2::is.ggplot(result$study_cond_plot))

  vdiffr::expect_doppelganger(
    title="plot-study-conditions-1",
    result$study_cond_plot
  )

})


