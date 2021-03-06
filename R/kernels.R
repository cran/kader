#2345678901234567890123456789012345678901234567890123456789012345678901234567890
### ~/PapersBooksReportsReviewsTheses/PapersSelbst/FestschriftWS70/kader/R/
###  kernels.R
### Kernel functions for "Kernel adjusted density estimation" of Srihera &
### Stute (2011) and for "Rank Transformations in Kernel Density Estimation"
### of Eichner & Stute (2013)
### R 3.4.1, 13./14.2./28.9.2017 (21./24./26./27./28./31.10./4./9.11./5.12.2016)
###*****************************************************************************

#' Epanechnikov kernel
#'
#' Vectorized evaluation of the Epanechnikov kernel.
#'
#' @param x Numeric vector.
#' @return A numeric vector of the Epanechnikov kernel evaluated at the
#'         values in \code{x}.
#'
#' @examples
#' kader:::epanechnikov(x = c(-sqrt(6:5), -2:2, sqrt(5:6)))
#' \donttest{
#' curve(kader:::epanechnikov(x), from = -sqrt(6), to = sqrt(6))
#' }
#'
epanechnikov <- function(x) {
  (abs(x) < sqrt(5)) * 3 / (4 * sqrt(5)) * (1 - x*x / 5)
}


#' Rectangular kernel
#'
#' Vectorized evaluation of the rectangular kernel.
#'
#' @param x Numeric vector.
#' @param a Numeric scalar: lower bound of kernel support; defaults to -0.5.
#' @param b Numeric scalar: upper bound of kernel support; defaults to 0.5.
#' @return A numeric vector of the rectangular kernel evaluated at the
#'         values in \code{x}.
#' @examples
#' kader:::rectangular(x = seq(-1, 1, by = 0.1))
#' \donttest{
#' curve(kader:::rectangular(x), from = -1, to = 1)
#' }
#'
rectangular <- function(x, a = -0.5, b = 0.5) {
  (a < x & x < b) / (b - a)
}
