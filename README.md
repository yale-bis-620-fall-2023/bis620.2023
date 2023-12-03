
# BIS 620 HW 3 R Project

This R shiny app shows query results and visual summarries of US (gov)
clinical trials data. An overview of app features is provided below.

<!-- badges: start -->

[![R-CMD-check](https://github.com/yale-bis-620-fall-2023/bis620.2023/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/yale-bis-620-fall-2023/bis620.2023/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

Links to
[coverage](https://github.com/yale-bis-620-fall-2023/bis620.2023/actions/workflows/test-coverage.yaml)
page and
[lint](https://github.com/yale-bis-620-fall-2023/bis620.2023/actions/workflows/lint.yaml)
results.

Overview of problem solutions and features added.

## Installation

You can install the development version of bis620.2023 from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("yale-bis-620-fall-2023/bis620.2023")
```

## Getting access to ctgov data

(If a local copy of the full database is required.)

``` r
# ONLY RUN THIS ONCE!
ctgov_get_latest_snapshot()
```

## App Overview

The shiny app contains 4 main tabs with 3 potential filters. The four
main tabs are - Clinical Trial Phase Histogram Based on
`Brief title keywords` search and `Sponsor Type` displays counts of each
clinical trial phase present. - Concurrent studies Times series plot of
concurrent trials for a given date. - Trial conditions
`Top No Trial Conditions` bar plot. Results are also based on
`Brief title keywords` search and `Sponsor Type`. - Trial db query
results. Table of query search (based on `Brief title keywords` search
and `Sponsor Type`.)

The 3 filters are query key-words, clinical trial sponsor type, and top
N trial conditons to query and display.

### New Features (from midterm)

#### P1) Clinical Phase Histogram

To standardize the x-axis, I defined `study_phases_u` in `ct-util.R`,
which is the set of unique study phases. I made an extra pre-processing
step to recode `NA` as `'Missing'`.

I re-factored `plot_phase_histogram` to include an argument for
`phase_labels` that defaults to `study_phases_u`. I also added an
optional for dropping or ignoring `'Not Applicable'` phase label,
setting `TRUE` as the default.

#### P2) New Tab for Historgram Queried, Trial Conditions

I have created an additional `TabPanel` called `Trial Conditions`, which
displays the output of `plot_study_conditions_histogram`. This function
has two helper functions: `get_study_conditions` and
`summarize_study_conditions`.

The former collects the desired data from the `conditions` table, and
the latter aggregates the data to enable visual. I provide the user
option to determine the “top_n” conditions to display. I did consider
lumping factors and did partially implement, but did not have the time
to properly integrate into the app.

I added an extra feature of flipping the axes if more than 6 conditions
are shown to avoid cluttering on the axis labels.

#### P3) Add a drop-down menu to subset queries on sponsor tpye

I created an additional `selectInput` called `sponsor_type` and use it
to filter `studies_df` within my `observeEvent` logic.

#### P4) New app features added.

I mainly implemented 1 main feature that induced a series of notable
changes for the app. I appreciated the `dataTableOutput` we had in the
`mainPanel` that would display our keyword query results. However, I
also wanted access to the aggregate data we used to display in each tab.
Therefore, in order to implement that and have the table displayed match
the visual being shown, I moved the query results data table into its
own tab, and in the other three tabs, displayed the corresponding table
(matching the visual created) in the `mainPanel` below the
`tabsetPanel`.

In having dynamic tables displayed for each tab, I had to replace the
main `reactive({})` logic with `observeEvent({})`. In being able to
consolidate all my logic here and makes call to various `reactiveVal()`
objects I at the top of my server function, I do think my app is slower
to process and update based on changes as it is updating all tabs
(visuals and tables), when a user input changes.

If given more time, I would allow the user to access all trial
conditions under the `Trial Conditions` tab rather than all the `top_n`
conditions queried.

My option to let a let user select the `top_n` conditions to visualize
in the `Trial Conditions` is another but less important feature I
created. This seemed like a reasonable extension to the app so users
could create a histogram of interest to them.
