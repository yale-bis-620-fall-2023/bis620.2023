% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ct-util.R
\name{query_kwds}
\alias{query_kwds}
\title{Query keywords from a database table.}
\usage{
query_kwds(df, kwds, column, ignore_case = TRUE, match_all = FALSE)
}
\arguments{
\item{df}{the database table.}

\item{kwds}{the keywords to look for.}

\item{column}{the column to look for the keywords in.}

\item{ignore_case}{should the case be ignored when searching for a keyword?
(default TRUE)}

\item{match_all}{should we look for values that match all of the keywords
(intersection) or any of the keywords (union)? (default FALSE; union).}
}
\value{
Data frame with filtered results based on keywords provided.
}
\description{
Process user input keywords to filter database table.
}
