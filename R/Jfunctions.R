#2345678901234567890123456789012345678901234567890123456789012345678901234567890
### ~/PapersBooksReportsReviewsTheses/PapersSelbst/FestschriftWS70/kader/R/
###  Jfunctions.R
### Fcts. related to the optimal transformation (J) in "Rank Transformations
### in Kernel Density Estimation" of Eichner & Stute (2013), like the solution
### J to the isoperimetric problem.
### R 3.4.2, 10./12./13./16.2./21./22./24.8./27./28.9./4.10.2017
###  (27./31.10./16.11./5.12.2016)
###*****************************************************************************

#' Cube-root that retains its argument's sign
#'
#' Computes \eqn{(x_1^{1/3}, \ldots, x_n^{1/3})} with \eqn{x_i^{1/3}} being
#' negative if \eqn{x_i < 0}.
#'
#' @param x Numeric vector.
#' @return Vector of same length and mode as input.
#'
#' @examples
#' kader:::cuberoot(x = c(-27, -1, -0, 0, 1, 27))
#' \donttest{
#' curve(kader:::cuberoot(x), from = -27, to = 27)
#' }
#'
cuberoot <- function(x) {
  sign(x) * abs(x)^(1/3)
}



#' pc
#'
#' Coefficient \eqn{p_c} of eq. (15.15) in Eichner (2017).
#'
#' p_c = 1/5 * (3c^2 - 5) / (3 - c^2) * c^2.
#'
#' For further details see p. 297 f. in Eichner (2017) and/or Eichner & Stute
#' (2013).
#'
#' @export
#' @param cc Numeric vector.
#' @return Vector of same length and mode as \code{cc}.
#'
#' @note \eqn{p_c} should be undefined for \eqn{c = \sqrt 3}, but \code{pc}
#'       is here implemented to return \code{Inf} in each element of its
#'       return vector for which the corresponding element in \code{cc}
#'       contains R's value of \code{sqrt(3)}.
#'
#' @examples
#' \donttest{
#' c0 <- expression(sqrt(5/3))
#' c1 <- expression(sqrt(3) - 0.01)
#' cgrid <- seq(1.325, 1.7, by = 0.025)
#' cvals <- c(eval(c0), cgrid, eval(c1))
#'
#' plot(cvals, pc(cvals), xaxt = "n", xlab = "c", ylab = expression(p[c]))
#' axis(1, at = cvals, labels = c(c0, cgrid, c1), las = 2)
#' }
#'
pc <- function(cc) {
  cc2 <- cc*cc
  res <- (3*cc2 - 5) / (3 - cc2) * cc2 / 5
  issqrt3 <- sapply(cc, function(x) isTRUE(all.equal(x, sqrt(3))))
  res[issqrt3] <- Inf
  res
}



#' qc
#'
#' Coefficient \eqn{q_c(u)} of eq. (15.15) in Eichner (2017).
#'
#' \eqn{q_c(u) = 2/5 * c^5 / (3 - c^2) * (1 - 2 * u)}
#'
#' For further details see p. 297 f. in Eichner (2017) and/or Eichner & Stute
#' (2013).
#'
#' @export
#' @param u Numeric vector.
#' @param cc Numeric constant, defaults to \eqn{\sqrt(5/3)}.
#' @return Vector of same length and mode as \code{u}.
#'
#' @note \eqn{q_c(u)} should be undefined for \eqn{c = \sqrt 3}, but \code{qc}
#'       is here implemented to return \code{Inf * (1 - 2*u)} if \code{cc}
#'       contains R's value of \code{sqrt(3)}.
#'
#' @examples
#' \donttest{
#' u <- c(0, 1)   # seq(0, 1, by = 0.1)
#' c0 <- expression(sqrt(5/3))
#' c1 <- expression(sqrt(3) - 0.05)
#' cgrid <- seq(1.4, 1.6, by = 0.1)
#' cvals <- c(eval(c0), cgrid, eval(c1))
#'
#' Y <- sapply(cvals, function(cc, u) qc(u, cc = cc), u = u)
#' cols <- rainbow(ncol(Y), end = 9/12)
#' matplot(u, Y, type = "l", lty = "solid", col = cols,
#'   ylab = expression(q[c](u)))
#' abline(h = 0, lty = "dashed")
#' legend("topright", title = "c", legend = c(c0, cgrid, c1),
#'   lty = 1, col = cols, cex = 0.8)
#' }
#'
qc <- function(u, cc = sqrt(5/3)) {
  if(!is.numeric(cc) || length(cc) > 1)
    stop("cc must be a numeric vector of length 1!")
  cc2 <- cc*cc
  if(isTRUE(all.equal(3, cc2))) {
    return(Inf * (1 - 2*u))
  } else return(2/5 * cc*cc2*cc2 / (3 - cc2) * (1-2*u))
}



#' J1
#'
#' Eq. (15.16) in Eichner (2017) as a result of Cardano's formula.
#'
#' Using, for brevity's sake, \eqn{J_{1a}(u, c) := -q_c(u)} and
#' \eqn{J_{1b}(u, c) := J_{1a}(u, c)^2 + p_c^3}, the definition of
#' \eqn{J_1} reads:
#'
#' \eqn{J_1(u, c) :=   [J_{1a}(u, c) + \sqrt(J_{1b}(u, c))]^{1/3}
#'                   + [J_{1a}(u, c) - \sqrt(J_{1b}(u, c))]^{1/3}}.
#'
#' For implementation details of \eqn{q_c(u)} and \eqn{p_c} see
#' \code{\link{qc}} and \code{\link{pc}}, respectively.
#'
#' For further mathematical details see Eichner (2017) and/or Eichner
#' & Stute (2013).
#'
#' @export
#' @inheritParams qc
#' @return Vector of same length and mode as \code{u}.
#'
#' @note Eq. (15.16) in Eichner (2017), and hence \eqn{J_1(u, c)}, requires
#'       \eqn{c} to be in \eqn{[\sqrt(5/3), 3)}. If \code{cc} does
#'       not satisfy this requirement a warning (only) is issued.
#'
#' @seealso \code{\link{J_admissible}}.
#'
#' @examples
#' \donttest{
#' u <- seq(0, 1, by = 0.01)
#' c0 <- expression(sqrt(5/3))
#' c1 <- expression(sqrt(3) - 0.01)
#' cgrid <- c(1.35, seq(1.4, 1.7, by = 0.1))
#' cvals <- c(eval(c0), cgrid, eval(c1))
#'
#' Y <- sapply(cvals, function(cc, u) J1(u, cc = cc), u = u)
#' cols <- rainbow(ncol(Y), end = 9/12)
#' matplot(u, Y, type = "l", lty = "solid", col = cols,
#'   ylab = expression(J[1](u, c)))
#' abline(h = 0)
#' legend("topleft", title = "c", legend = c(c0, cgrid, c1),
#'   lty = 1, col = cols, cex = 0.8)
#' }
#'
J1 <- function(u, cc = sqrt(5/3)) {
  if(!is.numeric(cc) || length(cc) > 1)
    stop("cc must be a numeric vector of length 1!")
  if(cc >= sqrt(3) || cc < sqrt(5/3))
    warning( "cc should be in [sqrt(5/3), 3)!")

  J1a <- -qc(u, cc)
  pc0 <- pc(cc)
  J1b <- J1a*J1a + pc0*pc0*pc0
  cuberoot(J1a + sqrt(J1b)) + cuberoot(J1a - sqrt(J1b))
}



#' J2
#'
#' Eq. (20) in Eichner (2017) (based on "Bronstein's formula for k = 3")
#'
#' \eqn{J_2(u, c) = 2\sqrt(-p_c) * sin(1/3 * arcsin(q_c(u) / (-p_c)^{3/2}))}
#'
#' For implementation details of \eqn{q_c(u)} and \eqn{p_c} see
#' \code{\link{qc}} and \code{\link{pc}}, respectively.
#'
#' For further mathematical details see Eichner (2017) and/or Eichner &
#' Stute (2013).
#'
#' @export
#' @param u Numeric vector.
#' @param cc Numeric constant, defaults to \eqn{\sqrt 5}.
#' @return Vector of same length and mode as \code{u}.
#'
#' @note Eq. (20) in Eichner (2017), and hence \eqn{J_2(u, c)}, requires
#'       \eqn{c} to be in \eqn{(\sqrt 3, \sqrt 5]}. If \code{cc} does
#'       not satisfy this requirement (only) a warning is issued.
#'
#'       The default \code{cc = sqrt(5)} yields the optimal rank
#'       transformation.
#'
#' @seealso \code{\link{J_admissible}}.
#'
#' @examples
#' \donttest{
#' u <- seq(0, 1, by = 0.01)
#' c0 <- expression(sqrt(3) + 0.01)
#' c1 <- expression(sqrt(5))
#' cgrid <- seq(1.85, 2.15, by = 0.1)
#' cvals <- c(eval(c0), cgrid, eval(c1))
#'
#' Y <- sapply(cvals, function(cc, u) J2(u, cc = cc), u = u)
#' cols <- rainbow(ncol(Y), end = 9/12)
#' matplot(u, Y, type = "l", lty = "solid", col = cols,
#'   ylab = expression(J[2](u, c)))
#' abline(h = 0)
#' legend("topleft", title = "c", legend = c(c0, cgrid, c1),
#'   lty = 1, col = cols, cex = 0.8)
#' }
#'
J2 <- function(u, cc = sqrt(5)) {
  if(!is.numeric(cc) || length(cc) > 1)
    stop("cc must be a numeric vector of length 1!")
  if(cc <= sqrt(3) || cc > sqrt(5))
    warning( "cc should be in (sqrt(3), sqrt(5)]!")
  root <- sqrt(-pc(cc))
  qq <- qc(u, cc)
  asin.arg <- ifelse(qq == 0, 0, qq / (root*root*root))
              # To manage "0/0" correctly whenever cc = 0.
  asin.arg <- pmax(pmin(asin.arg, 1), -1) # To assure |asin.arg| <= 1.
  2 * root * sin(asin(asin.arg) / 3)
}



#' Admissible Rank Transformations of Eichner & Stute (2013)
#'
#' This is just a wrapper for the functions \code{\link{J1}}, \code{\link{J2}},
#' and \eqn{u -> \sqrt 3 * (2u - 1)} which implement the admissible
#' transformations for the three cases for \eqn{c}. For mathematical
#' details see eq. (15.16) and (15.17) in Eichner (2017) and/or Eichner &
#' Stute (2013).
#'
#' Basically, for \code{cc} in \eqn{[\sqrt(5/3), \sqrt 5]}:
#'
#' \code{J_admissible(u, cc)} = \code{J1(u, cc)} if \code{cc} \eqn{< \sqrt 3},
#'
#' \code{J_admissible(u, cc)} = \code{J2(u, cc)} if \code{cc} \eqn{> \sqrt 3},
#' and
#'
#' \code{J_admissible(u, cc)} = \code{sqrt(3) * (2*u - 1)} if \code{cc}
#' \eqn{= \sqrt 3}.
#'
#' @export
#' @inheritParams J2
#' @return Vector of same length and mode as \code{u}.
#'
#' @note The admissible rank transformations require \eqn{c} to
#'       be in \eqn{[\sqrt(5/3), \sqrt 5]}. If \code{cc} does
#'       not satisfy this requirement a warning (only) is issued.
#'       The default \code{cc = sqrt(5)}, i.e., \eqn{c = \sqrt 5},
#'       yields the optimal rank transformation.
#'
#' @seealso \code{\link{J1}} and \code{\link{J2}}.
#'
#' @examples
#' \donttest{
#' par(mfrow = c(1, 2), mar = c(3, 3, 0.5, 0.5), mgp = c(1.7, 0.7, 0))
#' example(J1)
#' example(J2)
#' }
#'
J_admissible <- function(u, cc = sqrt(5)) {
  if(!is.numeric(cc) || length(cc) > 1)
    stop("cc must be a numeric vector of length 1.")
  if(cc < sqrt(5/3) || cc > sqrt(5))
    stop("cc is out of the admissible range [sqrt(5/3), sqrt(5)]!")
  if(cc < sqrt(3)) {
    J1(u, cc)               # eq. (15.16) in Eichner (2017)
  } else if(cc > sqrt(3)) {
    J2(u, cc)               # eq. (15.17) in Eichner (2017)
  } else {   # cc = sqrt(3)
   sqrt(3) * (2*u - 1)
  }
}
