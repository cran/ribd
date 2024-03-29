% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/twoLocusPlot.R
\name{twoLocusPlot}
\alias{twoLocusPlot}
\title{Two-locus coefficient plot}
\usage{
twoLocusPlot(
  peds,
  coeff = "k11",
  rseq = seq(0, 0.5, length = 11),
  xlab = "Recombination rate",
  ylab = NA,
  col = seq_along(peds),
  lty = 1,
  lwd = 1,
  ...
)
}
\arguments{
\item{peds}{A list of lists. See details.}

\item{coeff}{A string identifying which coefficient to compute. See Details
for legal values.}

\item{rseq}{A numeric vector of recombination rates. By default \code{seq(from = 0, by = 0.5, length = 11)}.}

\item{xlab, ylab}{Axis labels.}

\item{col, lty, lwd}{Plotting parameters.}

\item{...}{Further parameters passed on to \code{\link[=matplot]{matplot()}}.}
}
\description{
Plot two-locus kinship or IBD coefficients as function of the recombination
rate.
}
\details{
Each entry of \code{peds} must be a list with the following (named) entries:
\itemize{
\item ped: A ped object
\item ids: A pair of labels identifying two members of \code{ped}
}

The \code{coeff} parameter must be either a character naming the coefficient to
compute, or a function. If a character, it must be one of the following
names: "inb", "kinship", "phi", "phi11", "k00", "k01", "k02", "k10", "k11", "k12",
"k20", "k21" or "k22".

If \code{coeff} is a function, it must take three arguments named \code{ped}, \code{ids} and
\code{rho}, and produce a single number for each set of input data. See Examples.

The first three are synonymous and indicate the two-locus kinship
coefficient. The remaining choices are two-locus IBD coefficients. (See
\code{\link[=twoLocusIBD]{twoLocusIBD()}}.)
}
\examples{

###############################
# Classic example of three relationships with equal one-locus coeffs
peds = list(
    GrandParent = list(ped = linearPed(2),   ids = c(1, 5)),
    HalfSib     = list(ped = halfSibPed(),   ids = c(4, 5)),
    Uncle       = list(ped = avuncularPed(), ids = c(3, 6)))

twoLocusPlot(peds, coeff = "kinship")
twoLocusPlot(peds, coeff = "k11")

###############################

peds = list(
    PO = list(ped = nuclearPed(1), ids = c(1,3)),
    S  = list(ped = nuclearPed(2), ids = c(3,4)))

twoLocusPlot(peds, coeff = "kinship")
twoLocusPlot(peds, coeff = "k11")

###############################

ped1 = addChildren(halfSibPed(sex2 = 2), 4, 5, nch = 2)
ped2 = addChildren(linearPed(2, sex = 1:2), 1, 5, nch = 2)
ped3 = addChildren(avuncularPed("uncle", "niece"), 3, 6, nch = 2)

peds = list(
   `H-sibs` = list(ped = ped1, ids = leaves(ped1)),
   `G-sibs` = list(ped = ped2, ids = leaves(ped2)),
   `U-sibs` = list(ped = ped3, ids = leaves(ped3))
)
# plotPedList(peds)
twoLocusPlot(peds, coeff = "kinship")

################################

### Reproducing Fig 2 of Bishop & Williamson (1990)
### This example illustrates `coeff` as a function.

# The coefficient d11(rho) is the conditional probability of IBD = 1
# in the first locus, given IBD = 1 in the second.

G = linearPed(2)
H = halfSibPed()
U = avuncularPed()
FC = cousinPed(1)
FC1R = cousinPed(1, removal = 1)
SC = cousinPed(2)

peds = list(
    GrandParent = list(ped = G,    ids = c(1, 5)),
    HalfSib     = list(ped = H,    ids = leaves(H)),
    Uncle       = list(ped = U,    ids = leaves(U)),
    FirstCous   = list(ped = FC,   ids = leaves(FC)),
    FirstCous1R = list(ped = FC1R, ids = leaves(FC1R)),
    SecondCous  = list(ped = SC,   ids = leaves(SC)))


d11 = function(ped, ids, rho) {
  twoLocusIBD(ped, ids, rho, coefs = "k11")/kappaIBD(ped, ids)[2]
}

twoLocusPlot(peds, coeff = d11)

}
