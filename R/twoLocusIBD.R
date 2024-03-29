#' Two-locus IBD coefficients
#'
#' Computes the 3*3 matrix of two-locus IBD coefficients of a pair of non-inbred
#' pedigree members, for a given recombination rate.
#'
#' Let A, B be two pedigree members, and L1, L2 two loci with a given
#' recombination rate \eqn{\rho}. The two-locus IBD coefficients
#' \eqn{\kappa_{i,j}(\rho)}{\kappa_ij(\rho)}, for \eqn{0 \le i,j \le 2} are
#' defined as the probability that A and B have `i` alleles IBD at L1 and `j`
#' alleles IBD at L2 simultaneously. Note that IBD alleles at the two loci are
#' not required to be _in cis_ (or _in trans_ for that matter).
#'
#' The method of computation depends on the (single-locus) IBD coefficient
#' \eqn{\kappa_2}. If this is zero (e.g. if A is a direct ancestor of B, or vice
#' versa) the two-locus IBD coefficients are easily computable from the
#' two-locus kinship coefficients, as implemented in [twoLocusKinship()]. In the
#' general case, the computation is more involved, requiring _generalised
#' two-locus kinship_ coefficients. This is implemented in the function
#' `twoLocusGeneralisedKinship()`, which is not exported yet.
#'
#' @param x A pedigree in the form of a [`pedtools::ped`] object.
#' @param ids A character (or coercible to character) containing ID labels of
#'   two pedigree members.
#' @param rho A number in the interval \eqn{[0, 0.5]}; the recombination rate
#'   between the two loci.
#' @param coefs A character indicating which coefficient(s) to compute. A subset
#'   of `c('k00', 'k01', 'k02', 'k10', 'k11', 'k12', 'k20', 'k21', 'k22')`. By
#'   default, all coefficients are computed.
#' @param detailed A logical, indicating whether the condensed (default) or
#'   detailed coefficients should be returned.
#' @param uniMethod Either 1 or 2 (for testing purposes)
#' @param verbose A logical.
#'
#' @return By default, a symmetric 3*3 matrix containing the two-locus IBD
#'   coefficients \eqn{\kappa_{i,j}}{\kappa_ij}.
#'
#'   If either `coefs` is explicitly given (i.e., not NULL), or `detailed =
#'   TRUE`, the computed coefficients are returned as a named vector.
#'
#' @seealso [twoLocusKinship()], [twoLocusIdentity()], [twoLocusPlot()]
#'
#' @examples
#' # Plot title used in several examples below
#' main = expression(paste("Two-locus IBD:  ", kappa[`1,1`]))
#'
#' ###################################################################
#' # Example 1: A classic example of three relationships with the same
#' # one-locus IBD coefficients, but different two-locus coefficients.
#' # As a consequence, these relationships cannot be separated using
#' # unlinked markers, but are (theoretically) separable with linked
#' # markers.
#' ###################################################################
#' peds = list(
#'     GrandParent = list(ped = linearPed(2),   ids = c(1, 5)),
#'     HalfSib     = list(ped = halfSibPed(),   ids = c(4, 5)),
#'     Uncle       = list(ped = avuncularPed(), ids = c(3, 6)))
#'
#' twoLocusPlot(peds, coeff = "k11", main = main, lty = 1:3, col = 1)
#'
#'
#' ############################################################
#' # Example 2: Inspired by Fig. 3 in Thompson (1988),
#' # and its erratum: https://doi.org/10.1093/imammb/6.1.1.
#' #
#' # These relationships are also analysed in ?twoLocusKinship,
#' # where we show that they have identical two-locus kinship
#' # coefficients. Here we demonstrate that they have different
#' # two-locus IBD coefficients.
#' ############################################################
#'
#' peds = list(
#'   GreatGrand = list(ped = linearPed(3),              ids = c(1, 7)),
#'   HalfUncle  = list(ped = avuncularPed(half = TRUE), ids = c(4, 7))
#' )
#'
#' twoLocusPlot(peds, coeff = "k11", main = main, lty = 1:2, col = 1)
#'
#'
#' ########################################################################
#' # Example 3: Fig. 15 of Vigeland (2021).
#' # Two-locus IBD of two half sisters whose mother have inbreeding
#' # coefficient 1/4. We compare two different realisations of this:
#' #   PO: the mother is the child of parent-offspring
#' #  SIB: the mother is the child of full siblings
#' #
#' # The fact that these relationships have different two-locus coefficients
#' # exemplifies that a single-locus inbreeding coefficient cannot replace
#' # the genealogy in analyses of linked loci.
#' ########################################################################
#'
#' po = addChildren(nuclearPed(1, sex = 2), 1, 3, nch = 1, sex = 2)
#' po = addDaughter(addDaughter(po, 4), 4)
#'
#' sib = addChildren(nuclearPed(2, sex = 1:2), 3, 4, nch = 1)
#' sib = addDaughter(addDaughter(sib, 5), 5)
#'
#' # plotPedList(list(po, sib), new = TRUE, title = c("PO", "SIB"))
#'
#' # List of pedigrees and ID pairs
#' peds = list(PO =  list(ped = po,  ids = leaves(po)),
#'             SIB = list(ped = sib, ids = leaves(sib)))
#'
#' twoLocusPlot(peds, coeff = "k11", main = main, lty = 1:2, col = 1)
#'
#'
#' ### Check against exact formulas
#' rho = seq(0, 0.5, length = 11)  # recombination values
#'
#' kvals = sapply(peds, function(x)
#'   sapply(rho, function(r) twoLocusIBD(x$ped, x$ids, r, coefs = "k11")))
#'
#' k11.po = 1/8*(-4*rho^5 + 12*rho^4 - 16*rho^3 + 16*rho^2 - 9*rho + 5)
#' stopifnot(all.equal(kvals[, "PO"], k11.po, check.names = FALSE))
#'
#' k11.s = 1/16*(8*rho^6 - 32*rho^5 + 58*rho^4 - 58*rho^3 + 43*rho^2 - 20*rho + 10)
#' stopifnot(all.equal(kvals[, "SIB"], k11.s, check.names = FALSE))
#'
#'
#' ################################################
#' # Example 4:
#' # The complete two-locus IBD matrix of full sibs
#' ################################################
#'
#' x = nuclearPed(2)
#' k2_mat = twoLocusIBD(x, ids = 3:4, rho = 0.25)
#' k2_mat
#'
#' ### Compare with exact formulas
#' IBDSibs = function(rho) {
#'   R = rho^2 + (1-rho)^2
#'   nms = c("ibd0", "ibd1", "ibd2")
#'   m = matrix(0, nrow = 3, ncol = 3, dimnames = list(nms, nms))
#'   m[1,1] = m[3,3] = 0.25 *R^2
#'   m[2,1] = m[1,2] = 0.5 * R * (1-R)
#'   m[3,1] = m[1,3] = 0.25 * (1-R)^2
#'   m[2,2] = 0.5 * (1 - 2 * R * (1-R))
#'   m[3,2] = m[2,3] = 0.5 * R * (1-R)
#'   m
#' }
#'
#' stopifnot(all.equal(k2_mat, IBDSibs(0.25)))
#'
#'
#' #####################################################
#' # Example 5: Two-locus IBD of quad half first cousins
#' #
#' # We use this to exemplify two simple properties of
#' # the two-locus IBD matrix.
#' #####################################################
#'
#' x = quadHalfFirstCousins()
#' ids = leaves(x)
#'
#' # First compute the one-locus IBD coefficients (= c(17, 14, 1)/32)
#' k1 = kappaIBD(x, ids)
#'
#' ### Case 1: Complete linkage (`rho = 0`).
#' # In this case the two-locus IBD matrix has `k1` on the diagonal,
#' # and 0's everywhere else.
#' k2_mat_0 = twoLocusIBD(x, ids = ids, rho = 0)
#'
#' stopifnot(all.equal(k2_mat_0, diag(k1), check.attributes = FALSE))
#'
#' #' ### Case 2: Unlinked loci (`rho = 0.5`).
#' # In this case the two-locus IBD matrix is the outer product of
#' # `k1` with itself.
#' k2_mat_0.5 = twoLocusIBD(x, ids = ids, rho = 0.5)
#' stopifnot(all.equal(k2_mat_0.5, k1 %o% k1, check.attributes = FALSE))
#'
#'
#' ########################################################
#' # Example 6: By Donnelly (1983) these relationships are
#' # genetically indistinguishable
#' ########################################################
#'
#' x1 = halfCousinPed(1)
#' x2 = halfCousinPed(0, removal = 2)
#' stopifnot(identical(
#'   twoLocusIBD(x1, ids = leaves(x1), rho = 0.25),
#'   twoLocusIBD(x2, ids = leaves(x2), rho = 0.25)))
#'
#'
#' ###########################################################
#' # Example 7: Detailed coefficients of double first cousins.
#' # Compare with exact formulas by Denniston (1975).
#' ###########################################################
#'
#' \dontrun{
#' x = doubleFirstCousins()
#' ids = leaves(x)
#' rho = 0.25
#'
#' kapDetailed = twoLocusIBD(x, ids, rho, detailed = TRUE)
#'
#' # Example 1 of Denniston (1975)
#' denn = function(rho) {
#'   F = (1-rho)^2 * (rho^2 + (1-rho)^2)/4 + rho^2/8
#'   U = 1 + 2*F
#'   V = 1 - 4*F
#'
#'   # Note that some of Denniston's definitions differ slightly;
#'   # some coefficients must be multiplied with 2
#'   c(k00 = U^2/4,
#'     k01 = U*V/8  *2,
#'     k02 = V^2/16,
#'     k10 = U*V/8  *2,
#'     k11.cc = F*U/2  *2,
#'     k11.ct = 0,
#'     k11.tc = 0,
#'     k11.tt = V^2/16  *2,
#'     k12.h = F*V/4  *2,
#'     k12.r = 0,
#'     k20 = V^2/16,
#'     k21.h = F*V/4  *2,
#'     k21.r = 0,
#'     k22.h = F^2,
#'     k22.r = 0)
#' }
#'
#' stopifnot(all.equal(kapDetailed, denn(rho)))
#' }
#'
#' @export
twoLocusIBD = function(x, ids, rho, coefs = NULL, detailed = FALSE, uniMethod = 1, verbose = FALSE) {
  if(!is.ped(x)) stop2("Input is not a `ped` object")
  if(length(ids) != 2) stop2("`ids` must have length exactly 2")

  # One-locus IBD coefficients (stop if anyone is inbred)
  kap = kappaIBD(x, ids, inbredAction = 2)

  # Enforce parents to precede their children
  if(!hasParentsBeforeChildren(x))
    x = parentsBeforeChildren(x)

  x = foundersFirst(x)

  # Setup memoisation
  mem = initialiseTwoLocusMemo(x, rho, counters = c("i", "itriv", "iimp", "ifound", "ilook", "irec"))
  mem$kappa = kap

  # Output format
  outputMatrix = is.null(coefs) && !detailed

  # Coefficient selection
  allcoefs = c("k00", "k01", "k02", "k10", "k11", "k12", "k20", "k21", "k22")
  if(any(!coefs %in% allcoefs))
    stop2("Invalid coefficient specified: ", setdiff(coefs, allcoefs), "\nSee ?twoLocusIBD for valid choices.")
  if(is.null(coefs))
    coefs = allcoefs

  # If kappa2 == 0: Use unilineal method
  if(kap[3] == 0) {
    if(verbose) message(sprintf("Unilineal relationship\n%s coefficients", if(detailed) "Detailed" else "Condensed"))
    RES = twoLocusIBD_unilineal(x, ids, rho, mem = mem, coefs = coefs,
                               detailed = detailed, uniMethod = uniMethod, verbose = verbose)
  }

  # If kappa2 > 0: Use bilineal method
  if(kap[3] > 0) {
    if(verbose) message(sprintf("Bilineal relationship\n%s coefficients", if(detailed) "Detailed" else "Condensed"))
    RES = twoLocusIBD_bilineal(x, ids, rho, mem = mem, coefs = coefs,
                                detailed = detailed, verbose = verbose)
  }

  ### Print summary
  if(verbose)
    printCounts2(mem)

  # Output
  if(outputMatrix) {
    dim(RES) = c(3, 3)
    dimnames(RES) = list(paste0("ibd", 0:2), paste0("ibd", 0:2))
  }

  RES
}


twoLocusIBD_unilineal = function(x, ids, rho, mem = NULL, coefs, detailed = FALSE, uniMethod = 1, verbose = FALSE) {

  if(is.null(mem)) {
    # Enforce parents to precede their children
    if(!hasParentsBeforeChildren(x))
      x = parentsBeforeChildren(x)

    x = foundersFirst(x)

    # Setup memoisation
    mem = initialiseTwoLocusMemo(x, rho, counters = c("i", "ilook", "ir", "b1", "b2", "b3"))
  }

  idsi = internalID(x, ids)
  id1 = idsi[1]
  id2 = idsi[2]
  rb = 1 - rho

  kap = if("kappa" %in% names(mem)) mem$kappa else kappaIBD(x, ids, inbredAction = 2)

  k11.cc = k11.ct = k11.tc = k11.tt = 0  # (Useful to define "default" values here)

  if(uniMethod == 1) {

    if(rho == 0.5) {
      k11 = kap[2]^2

      if(detailed && k11 > 0) {
        # Rectilineal?
        if(id1 %in% ancestors(x, id2, internal = TRUE)) {
          k11.cc = k11.tc = 0.5 * k11
        }
        else if(id2 %in% ancestors(x, id1, internal = TRUE)) {
          k11.cc = k11.ct = 0.5 * k11
        }
        else {
          RELATED = mem$k1 > 0

          # Note that neither id1 nor id2 are founders at this point: k1 > 0 and not rectilineal
          if(all(RELATED[parents(x, id1, internal = TRUE), id2])) {
            k11.cc = k11.tc = 0.5 * k11
          }
          else if(all(RELATED[parents(x, id2, internal = TRUE), id1])) {
            k11.cc = k11.ct = 0.5 * k11
          }
          else {
            k11.cc = k11
          }
        }
      }
    }
    else if(rho == 0) {
      k11 = k11.cc = kap[2]
    }
    else {# rho strictly between 0 and 0.5

      if(!detailed) {
        H = kin2L(x, locus1 = sprintf("%s>1 = %s>1 = %s>2 = %s>2", id1, id2, id1, id2),
                     locus2 = sprintf("%s>1 = %s>1,  %s>2,  %s>2", id1, id2, id1, id2), internal = TRUE)
        if(verbose)
          message("Unilineal method 1: Computing `k11` via generalised kinship pattern\n  ", formatKin2L(H))

        # Compute k11 via H
        h = genKin2L(H, mem, indent = NA)

        k11 = 16/(rho^2 * rb^2) * h
      }
      else {
        ## Compute 4 generalised coefs, solve for k11^cc etc.
        kin1 = kin2L(x, locus1 = sprintf("%s>1 = %s>1", id1, id2),
                        locus2 = sprintf("%s>1 = %s>1", id1, id2), internal = TRUE)
        h1 = genKin2L(kin1, mem, indent = NA)

        kin2 = kin2L(x, locus1 = sprintf("%s>1 = %s>1, %s>2", id1, id2, id2),
                        locus2 = sprintf("%s>1 = %s>2, %s>1", id1, id2, id2), internal = TRUE)
        h2 = genKin2L(kin2, mem, indent = NA)

        kin3 = kin2L(x, locus1 = sprintf("%s>1 = %s>1, %s>2", id1, id2, id1),
                        locus2 = sprintf("%s>2 = %s>1, %s>1", id1, id2, id1), internal = TRUE)
        h3 = genKin2L(kin3, mem, indent = NA)

        kin4 = kin2L(x, locus1 = sprintf("%s>1 = %s>1, %s>2, %s>2", id1, id2, id1, id2),
                        locus2 = sprintf("%s>2 = %s>2, %s>1, %s>1", id1, id2, id1, id2), internal = TRUE)
        h4 = genKin2L(kin4, mem, indent = NA)

        ### Solve for detailed k11
        bvec = c(4*h1, 8*h2, 8*h3, 16*h4)

        M = matrix(c(rb^2,     rb*rho,     rb*rho,      rho^2,
                     rb*rho^2, rb^3,       rho^3,       rb^2*rho,
                     rb*rho^2, rho^3,      rb^3,        rb^2*rho,
                     rho^4,    rb^2*rho^2, rb^2*rho^2,  rb^4),
                   byrow = TRUE, nrow = 4)

        m = round(solve(M, bvec), 15) # ad hoc rounding to avoid tiny errors. Better alternatives?

        # Minv = matrix(c(rb^4,      -rb^2*rho, -rb^2*rho,  rho^2,
        #                -rb^2*rho^2, rb^3,      rho^3,    -rb*rho,
        #                -rb^2*rho^2, rho^3,     rb^3,     -rb*rho,
        #                 rho^4,     -rb*rho^2, -rb*rho^2,  rb^2),
        #               byrow = TRUE, nrow = 4)/(rb^3 - rho^3)^2
        # print(round(M %*% Minv, 10))

        k11.cc = m[1]; k11.ct = m[2]; k11.tc = m[3]; k11.tt = m[4]

        # Total
        k11 = k11.cc + k11.ct + k11.tc + k11.tt
      }
    }
  } ### uniMethod 1 done
  else if(uniMethod == 2) {

    if(verbose)
      message("Unilineal method 2: Phased two-locus kinship coefficients")

    k11.cc = twoLocusKinship(x, ids, rho, recombinants = c(FALSE,FALSE)) * 4/(rb^2)

    if(rho > 0) {
      k11.ct = twoLocusKinship(x, ids, rho, recombinants = c(FALSE,TRUE)) * 4/(rho*rb)
      k11.tc = twoLocusKinship(x, ids, rho, recombinants = c(TRUE,FALSE)) * 4/(rho*rb)
      k11.tt = twoLocusKinship(x, ids, rho, recombinants = c(TRUE,TRUE)) * 4/(rho^2)
    }

    # Total
    k11 = k11.cc + k11.ct + k11.tc + k11.tt
  }

  ### k10
  k10 = k01 = kap[2] - k11

  ### k00
  k00 = kap[1] - k01

  ### Remaining are zero
  k20 = k02 = k21 = k12 = k22 = 0
  k12.h = k12.r = k21.h = k21.r = k22.h = k22.r = 0


  if(detailed) {
    coefList = list(
      k00 = "k00", k01 = "k01", k02 = "k02",
      k10 = "k10",
      k11 = c("k11.cc", "k11.ct", "k11.tc", "k11.tt"),
      k12 = c("k12.h", "k12.r"),
      k20 = "k20",
      k21 = c("k21.h", "k21.r"),
      k22 = c("k22.h", "k22.r"))

    coefs = unlist(coefList[coefs])
  }

  # Return the wanted coefficients (in the indicated order)
  unlist(mget(coefs))
}


twoLocusIBD_bilineal = function(x, ids, rho, mem = NULL, coefs, detailed = FALSE, verbose = FALSE) {

  if(any(ids %in% founders(x)))
    stop2("Both `ids` must be non-founders in order to use the bilinear method")

  if(is.null(mem)) {
    # Enforce parents to precede their children
    if(!hasParentsBeforeChildren(x))
      x = parentsBeforeChildren(x)

    x = foundersFirst(x)

    # Setup memoisation
    mem = initialiseTwoLocusMemo(x, rho, counters = c("i", "itriv", "iimp", "ifound", "ilook", "irec"))
  }

  # Detailed single-locus identity states (only noninbred states 9 - 15 are needed)
  idsi = internalID(x, ids)
  a = idsi[1]; b = idsi[2]
  f = father(x, a, internal = TRUE)
  g = father(x, b, internal = TRUE)
  m = mother(x, a, internal = TRUE)
  n = mother(x, b, internal = TRUE)

  S9  = sprintf("%s>%s = %s>%s, %s>%s = %s>%s", f,a, g,b, m,a, n,b)
  S10 = sprintf("%s>%s = %s>%s, %s>%s , %s>%s", f,a, g,b, m,a, n,b)
  S11 = sprintf("%s>%s = %s>%s, %s>%s , %s>%s", m,a, n,b, f,a, g,b)
  S12 = sprintf("%s>%s = %s>%s, %s>%s = %s>%s", f,a, n,b, m,a, g,b)
  S13 = sprintf("%s>%s = %s>%s, %s>%s , %s>%s", f,a, n,b, m,a, g,b)
  S14 = sprintf("%s>%s = %s>%s, %s>%s , %s>%s", m,a, g,b, f,a, n,b)
  S15 = sprintf("%s>%s , %s>%s, %s>%s , %s>%s", f,a, g,b, m,a, n,b)

  # Helper function for computing generalised two-locus coefs
  .Phi = function(loc1, loc2) {
    kin = kin2L(x, loc1, loc2, internal = TRUE)
    genKin2L(kin, mem, indent = NA)
  }

  ### Here starts the actual work! ###

  # If the condensed coefficients are wanted, use row sums to reduce work load!
  if(!detailed) {
    kap = mem$kappa

    # Compute corner entries (require fewest computations)
    k00 = .Phi(S15, S15)
    k20 = k02 = .Phi(S9, S15) + .Phi(S12, S15)
    k22.h = .Phi(S9, S9) + .Phi(S12, S12)
    k22.r = .Phi(S9, S12) * 2
    k22 = k22.h + k22.r

    # Remaining
    k01 = k10 = kap[1] - k00 - k02
    k21 = k12 = kap[3] - k20 - k22
    k11 = kap[2] - k10 - k12

    # Return the wanted coefficients (in the indicated order)
    return(unlist(mget(coefs)))
  }

  ### Detailed coefficients ###

  if("k22" %in% coefs) {
    k22.h = .Phi(S9, S9) + .Phi(S12, S12)
    k22.r = .Phi(S9, S12) * 2
  }

  if("k21" %in% coefs || "k12" %in% coefs) {
    # k21.h
    k21.h = k12.h = .Phi(S9, S10) + .Phi(S9, S11) + .Phi(S12, S13) + .Phi(S12, S14)

    # k21.r
    k21.r = k12.r = .Phi(S9, S13) + .Phi(S9, S14) + .Phi(S12, S10) + .Phi(S12, S11)
  }

  if("k20" %in% coefs || "k02" %in% coefs) {
    k20 = k02 = .Phi(S9, S15) + .Phi(S12, S15)
  }

  if("k11" %in% coefs) {
    # cis/cis
    k11.cc = .Phi(S10, S10) + .Phi(S11, S11) + .Phi(S13, S13) + .Phi(S14, S14)

    # cis/trans
    k11.ct = 2 * (.Phi(S10, S13) + .Phi(S11, S14))

    # trans/cis
    k11.tc = 2 * (.Phi(S10, S14) + .Phi(S11, S13))

    # trans/trans
    k11.tt = 2 * (.Phi(S10, S11) + .Phi(S13, S14))
  }

  if("k10" %in% coefs || "k01" %in% coefs) {
    k10 = k01 = .Phi(S10, S15) + .Phi(S11, S15) + .Phi(S13, S15) + .Phi(S14, S15)
  }

  if("k00" %in% coefs) {
    k00 = .Phi(S15, S15)
  }


  coefList = list(
    k00 = "k00", k01 = "k01", k02 = "k02",
    k10 = "k10",
    k11 = c("k11.cc", "k11.ct", "k11.tc", "k11.tt"),
    k12 = c("k12.h", "k12.r"),
    k20 = "k20",
    k21 = c("k21.h", "k21.r"),
    k22 = c("k22.h", "k22.r"))

  coefs = unlist(coefList[coefs])

  # Return the wanted coefficients (in the indicated order)
  unlist(mget(coefs))
}


twoLocusIBD_simple = function(x, ids, rho) {
  id1 = ids[1]
  id2 = ids[2]
  fa1 = father(x, id1)
  fa2 = father(x, id2)
  mo1 = mother(x, id1)
  mo2 = mother(x, id2)

  phi = kinship(x)

  # Matrix of two-locus kinship for all pairs
  # TODO: only include ids up to max(internalID(ids))
  phi11 = matrix(NA, ncol = pedsize(x), nrow = pedsize(x),
                 dimnames = list(labels(x), labels(x)))

  phi11.df = twoLocusKinship(x, ids = labels(x), rho)
  int1 = internalID(x, phi11.df$id1)
  int2 = internalID(x, phi11.df$id2)
  phi11[cbind(int1, int2)] = phi11[cbind(int2, int1)] = phi11.df$phi2

  # Derive similar matrices of phi10, phi01 and phi00
  phi01 = phi10 = phi - phi11
  phi00 = 1 - 2*phi + phi11

  # The following probabilities are known:
  k22.h = phi11[fa1, fa2] * phi11[mo1, mo2] + phi11[fa1, mo2] * phi11[mo1, fa2]
  k21.h = phi11[fa1, fa2] * phi10[mo1, mo2] + phi11[fa1, mo2] * phi10[mo1, fa2] +
    phi11[mo1, fa2] * phi10[fa1, mo2] + phi11[mo1, mo2] * phi10[fa1, fa2]
  k11.cc = phi11[fa1, fa2] * phi00[mo1, mo2] + phi11[fa1, mo2] * phi00[mo1, fa2] +
    phi11[mo1, fa2] * phi00[fa1, mo2] + phi11[mo1, mo2] * phi00[fa1, fa2]

  phi11.rr = twoLocusKinship(x, ids = ids, rho, recombinants = c(TRUE, TRUE))
  k11.tt = phi11.rr * 4/rho^2 - 2*k22.h - 2*k21.h

  k00 = phi00[fa1, fa2] * phi00[fa1, mo2] * phi00[mo1, fa2] * phi00[mo1, mo2]
  return(c(k22.h = k22.h, k21.h = k21.h, k11.cc = k11.cc, k11.tt = k11.tt, k00 = k00))
}
