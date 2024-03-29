% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ibdTriangle.R
\name{showInTriangle}
\alias{showInTriangle}
\title{Add points to the IBD triangle}
\usage{
showInTriangle(
  kappa,
  plotType = c("base", "ggplot2", "plotly"),
  new = TRUE,
  ped = NULL,
  pedBL = c(0.5, 0.5),
  pedArgs = NULL,
  col = 6,
  cex = 1,
  pch = 4,
  lwd = 2,
  jitter = NULL,
  labels = NULL,
  colLab = col,
  cexLab = 0.8,
  labSep = "-",
  pos = 1,
  adj = NULL,
  keep.par = TRUE,
  ...
)
}
\arguments{
\item{kappa}{Coordinates of points to be plotted in the IBD triangle. Valid
input types are:
\itemize{
\item A numerical vector of length 2 (kappa0, kappa2) or 3 (kappa0, kappa1,
kappa2). In the latter case kappa1 is ignored.
\item A matrix of data frame, whose column names must include either \code{k0} and
\code{k2}, \code{kappa0} and \code{kappa2}, or \code{ibd0} and \code{ibd2}.
\item A list (and not a data frame), in which case an attempt is made to bind
the elements row-wise.
}}

\item{plotType}{Either "base" (default), "ggplot2" or "plotly". Abbreviations
are allowed.}

\item{new}{A logical indicating if a new triangle should be drawn.}

\item{ped}{A pedigree to be drawn in the upper right corner of the plot.
Default: NULL. This only works when \code{plotType} is \code{base} or \code{ggplot2}.}

\item{pedBL}{A vector of length two, with entries in \verb{[0,1]}, indicating the
coordinates of the bottom left corner. Default: \code{c(0.5, 0.5)}.}

\item{pedArgs}{Plotting arguments for the inset pedigree. Default: NULL.}

\item{col, cex, pch, lwd}{Parameters controlling the appearance of points.}

\item{jitter}{A logical. If NULL (default), jittering is disabled for
\code{plotType}'s "base" or "ggplot2" and enabled for "plotly".}

\item{labels}{A character of same length as the number of points, or a single
logical \code{TRUE} or \code{FALSE}. If \code{TRUE}, labels are created by pasting columns
\code{id1} and \code{id2} in \code{kappa} (if these exist) separated by \code{labSep}. By
default, labels are disabled when \code{plotType = "base"}, enabled if \code{plotType = "ggplot2"} and enabled (interactively) if \code{plotType = "plotly"}.}

\item{colLab, cexLab, pos, adj}{Parameters controlling the appearance of labels.
Ignored when \code{plotType = "plotly"}.}

\item{labSep}{A string, by default "-".}

\item{keep.par}{A logical. If TRUE (and \code{plotType = "base"}), the graphical
parameters are not reset after plotting, which may be useful for adding
additional annotation.}

\item{\dots}{Plot arguments passed on to \code{ibdTriangle()}.}
}
\value{
If \code{plotType = 'base'}, the function returns NULL; otherwise the plot
object.
}
\description{
Utility function for plotting kappa coefficients in the IBD triangle. This
was previously only implemented as a base R plot, but is now also available
in \code{ggplot2} and \code{plotly} formats, controlled by the argument \code{plotType}.
Labels are often easier to read in the two latter versions: The \code{ggplot2}
version uses \code{ggrepel} to separate labels, while \code{plotly} enables interactive
exploration of the plot.
}
\examples{
showInTriangle(c(3/8, 1/8), label = "3/4 siblings", pos = 1)

# With inset pedigree
x = doubleCousins(1, 0, half2 = TRUE)
showInTriangle(c(3/8, 1/8), label = "3/4 siblings", pos = 1,
               ped = x, pedArgs = list(hatched = 6:7))

# All pairs
k = kappaIBD(x)
showInTriangle(k, labels = TRUE, pos = 1:4, ped = x)

# With jitter and variable colors
showInTriangle(k, labels = TRUE, pos = 1:4, jitter = TRUE, col = 1:7, ped = x)

# Separate labels (requires ggplot2 + ggrepel)
# showInTriangle(k, plot = "ggplot2", col = 2:8, ped = x)

# Interactive plot (requires plotly)
# showInTriangle(k, plot = "plotly", col = 2:8, pch = 0)

}
\seealso{
\code{\link[=ibdTriangle]{ibdTriangle()}}, \code{\link[=kappaIBD]{kappaIBD()}}
}
