#' Inbreeding coefficients
#'
#' Compute the inbreeding coefficients of all members of a pedigree. These are
#' simple wrappers of [kinship()] and [kinshipX()]. The founders
#' may be inbred; see [pedtools::founderInbreeding()] for how to set this up.
#'
#' The autosomal inbreeding coefficient of a pedigree member is defined as the
#' probability that, at a random autosomal locus, the two alleles carried by the
#' member are identical by descent relative to the pedigree. It follows from the
#' definition that the inbreeding coefficient of a member equals the kinship
#' coefficient of the parents.
#'
#' The X chromosomal inbreeding coefficient of an female member is defined
#' similarly to the autosomal case above. For males is it always 1.
#'
#' The inbreeding coefficients are computed from the kinship coefficients by the formula
#' \deqn{f_a = 2*\phi_{aa} - 1.}{f = 2*phi - 1.}
#'
#' @param x A pedigree, in the form of a [`pedtools::ped`] object.
#'
#' @return A numeric vector of length `pedsize(x)`.
#'
#' @seealso [kinship()]
#' @examples
#' # Child of half siblings: f = 1/8
#' x = halfCousinPed(0, child = TRUE)
#' inbreeding(x)
#'
#' # If the father is 100% inbred, the inbreeding coeff of the child doubles
#' founderInbreeding(x, 1) = 1
#' inbreeding(x)
#'
#' # The X inbreeding coefficients depend on the genders in the pedigree.
#' # To exemplify this, we look at a child of half siblings.
#'
#' x.pat = halfSibPed(sex2 = 2) # paternal half sibs
#' x.pat = addChildren(x.pat, father = 4, mother = 5, nch = 1, sex = 2)
#' stopifnot(inbreedingX(x.pat)[6] == 0)
#'
#' # Change to maternal half sibs => coeff becomes 1/4.
#' x.mat = swapSex(x.pat, 1)
#' stopifnot(inbreedingX(x.mat)[6] == 0.25)
#'
#' @export
inbreeding = function(x) {
  kin = kinship(x)
  2 * diag(kin) - 1
}

#' @rdname inbreeding
#' @export
inbreedingX = function(x) {
  kin = kinshipX(x)
  2 * diag(kin) - 1
}