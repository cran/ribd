#' Pedigree construction
#'
#' Construct a pedigree yielding a prescribed set of IBD coefficients.
#'
#' The construction follows the method and formulae given in Vigeland (2020).
#'
#' @param kappa A probability vector of length 3; \eqn{(kappa0, kappa1,
#'   kappa2)}{(\kappa_0, \kappa_1, \kappa_2)}.
#' @param describe A logical. If TRUE, a textual description of the resulting
#'   relationship is printed.
#' @param verbose A logical. If TRUE, various details about the calculations are
#'   printed.
#'
#' @return A `ped` object containing a pair of double half cousins with inbred
#'   founders. (In corner cases the relationship collapses into siblings.)
#'
#' @references M. D. Vigeland (2020). _Relatedness coefficients in pedigrees
#'   with inbred founders_. Journal of mathematical biology.
#'   \doi{https://doi.org/10.1007/s00285-020-01505-x}
#'
#' @examples
#'
#' # Full siblings
#' x = constructPedigree(kappa = c(0.25, 0.5, 0.25))
#' kappaIBD(x, leaves(x))
#'
#' # A relationship halfway between parent-child and full sibs
#' kap = c(1/8, 6/8, 1/8)
#' showInTriangle(kap, label = " (1/8, 1/8)", pos = 4)
#'
#' y = constructPedigree(kappa = kap)
#' plot(y)
#'
#' stopifnot(all.equal(kappaIBD(y, leaves(y)), kap))
#'
#' # kappa = (0,1,0) does not give a parent-child relationship,
#' # but half siblings whose shared parent is completely inbred.
#' z = constructPedigree(kappa = c(0,1,0))
#' plot(z)
#'
#' @export
constructPedigree = function(kappa, describe = TRUE, verbose = FALSE) {
  if(!is.numeric(kappa) || length(kappa) != 3)
    stop2("`kappa` must be a numeric vector of length 3")
  if(!all(kappa >= 0))
    stop2("All entries of `kappa` must be nonnegative")
  if(sum(kappa) != 1)
    stop2("The entries of `kappa` must sum to 1: ", sum(kappa))

  k0 = kappa[1]
  k1 = kappa[2]
  k2 = kappa[3]

  # If unrelated, return early
  if(k1 == 0 && k2 == 0) {
    if(describe)
      cat(glue::glue("Result:\n  Unrelated\n"))
    x = singletons(1:2)
    return(x)
  }

  U = 1 - k0 + k2
  D = U^2 - 4*k2 # = k1^2 - 4*k0*k2

  # Check that kappa is admissible (nonnegative discriminant)
  if(D < 0)
    stop2("`kappa` is inadmissible: k1^2 - 4*k0*k2 = ", D)

  # Kinship coefficients between fathers and mothers, respectively
  phi1 = 0.5*(U - sqrt(D))
  phi2 = 0.5*(U + sqrt(D))

  # Separations and founder inbreeding coeffs
  m = ceiling(log2(1/(U - sqrt(D))))
  n = ceiling(log2(1/(U + sqrt(D))))
  f1 = 2^m*(U - sqrt(D)) - 1
  f2 = 2^n*(U + sqrt(D)) - 1

  # Special fix in case phi = 1
  if(m == -1) {
    m = 0
    f1 = 1
  }
  if(n == -1) {
    n = 0
    f2 = 1
  }

  # Choose cousin degrees/removals
  deg1 = floor(m/2)
  deg2 = floor(n/2)
  rem1 = m - 2*deg1
  rem2 = n - 2*deg2

  if(verbose)
    message(glue::glue("
      Intermediate calculations (see Vigeland, 2020):
        discriminant: D = {D}

        paternal kinship:  phi1 = {round(phi1, 4)}
        paternal separation:  m = {m}
        paternal inbreeding: f1 = {round(f1, 4)}

        maternal kinship:  phi2 = {round(phi2, 4)}
        maternal separation:  n = {n}
        maternal inbreeding: f2 = {round(f2, 4)}\n
      "))

  # Special case: m = n = 0
  if(m + n == 0) {
    x = nuclearPed(2)
    founderInbreeding(x, 1:2) = c(f1, f2)

    if(describe)
      cat(glue::glue("
        Result:
          (Corner case with half-cousin degrees m = n = 0)
          Full siblings; founder inbreeding {round(f1, 4)} and {round(f2, 4)}\n
        "))

    return(x)
  }

  if(k2 == 0) {
    x = halfCousinPed(degree = deg2, removal = rem2)
    fou = commonAncestors(x, leaves(x))
    founderInbreeding(x, fou) = f2

    # Reorder so that cousins come at the end
    #ids = leaves(x)
    #labs = labels(x)
    #x = reorderPed(x, neworder = c(setdiff(labs, ids), ids))
    #x = relabel(x, new = 1:pedsize(x))

    msg = glue::glue("
      Result:
        Paternal half cousins of degree {deg2}, removal {rem2}; founder inbreeding {round(f2, 4)}\n
      ")
  }
  else {
    x = doubleCousins(degree1 = deg1, degree2 = deg2,
                      removal1 = rem1, removal2 = rem2,
                      half1 = TRUE, half2 = TRUE)
    ids = leaves(x)
    fou1 = commonAncestors(x, father(x, ids), inclusive = TRUE)
    fou2 = commonAncestors(x, mother(x, ids), inclusive = TRUE)

    # Reorder so that the inbred founders are 1 and 2, and cousins at the end
    #labs = labels(x)
    #x = reorderPed(x, neworder = c(fou1, fou2, setdiff(labs, c(fou1, fou2, ids)), ids))
    #x = relabel(x, new = 1:pedsize(x))

    # Set founder inbreeding
    founderInbreeding(x, fou1) = f1
    founderInbreeding(x, fou2) = f2

    msg = glue::glue("
      Result:
        Paternal half cousins of degree {deg1}, removal {rem1}; founder inbreeding {round(f1, 4)}
        Maternal half cousins of degree {deg2}, removal {rem2}; founder inbreeding {round(f2, 4)}\n
      ")
  }

  if(describe) {
    msg = gsub("cousins of degree 0, removal 0", "siblings", msg)
    msg = sub(", removal 0", "", msg)
    cat(msg)
  }

  x
}
