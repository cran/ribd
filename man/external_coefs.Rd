% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/external_relatedness.R
\name{external_coefs}
\alias{external_coefs}
\alias{kinship2_kinship}
\alias{kinship2_inbreeding}
\title{Relatedness coefficients by other programs}
\usage{
kinship2_kinship(x, ids = NULL, Xchrom = FALSE)

kinship2_inbreeding(x, Xchrom = FALSE)
}
\arguments{
\item{x}{A pedigree, in the form of a \code{\link[pedtools:ped]{pedtools::ped}} object.}

\item{ids}{A integer vector of length 2.}

\item{Xchrom}{A logical, indicating if the autosomal (default) or
X-chromosomal coefficients should be computed.}
}
\value{
For \code{kinship2_inbreeding()}, a numerical vector with inbreeding coefficients,
named with ID labels.

For \code{kinship2_kinship()}, either a single numeric (if \code{ids} is a pair of
pedigree members) or the whole kinship matrix, with the ID labels as
dimnames.
}
\description{
Wrappers for functions in other packages or external programs.
}
\details{
\code{kinship2_kinship()} and \code{kinship2_inbreeding()} both wrap
\code{\link[kinship2:kinship]{kinship2::kinship()}}.
}
\examples{
# A random pedigree with 7 individuals
p = randomPed(n = 7, seed = 123)

### Kinship matrix

# Autosomal: Check that ribd agrees with kinship2
stopifnot(identical(
  kinship(p),          # ribd
  kinship2_kinship(p)  # kinship2
))

# X chromosomal kinship
stopifnot(identical(
  kinship(p, Xchrom = TRUE),          # ribd
  kinship2_kinship(p, Xchrom = TRUE)  # kinship2
))


### Inbreeding coefficients

# Autosomal
stopifnot(identical(
  inbreeding(p),          # ribd
  kinship2_inbreeding(p)  # kinship2
))

# X chromosomal
stopifnot(identical(
  inbreeding(p, Xchrom = TRUE),          # ribd
  kinship2_inbreeding(p, Xchrom = TRUE)  # kinship2
))


}
\seealso{
\code{\link[kinship2:kinship]{kinship2::kinship()}}
}
