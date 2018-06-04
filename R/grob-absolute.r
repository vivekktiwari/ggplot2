#' Absolute grob
#'
#' This grob has fixed dimensions and position.
#'
#' It's still experimental
#'
#' @keywords internal
absoluteGrob <- function(grob, width = NULL, height = NULL,
  xmin = NULL, ymin = NULL, vp = NULL) {

  gTree(
    children = grob,
    width = width, height = height,
    xmin = xmin, ymin = ymin,
    vp = vp, cl = "absoluteGrob"
  )
}

#' @keywords internal
#' @method grobHeight absoluteGrob
grobHeight.absoluteGrob <- function(x) {
  x$height %||% grobHeight(x$children)
}
#' @keywords internal
#' @method grobWidth absoluteGrob
grobWidth.absoluteGrob <- function(x) {
  x$width %||%  grobWidth(x$children)
}

#' @keywords internal
#' @method grobX absoluteGrob
grobX.absoluteGrob <- function(x, theta) {
  if (!is.null(x$xmin) && theta == "west") return(x$xmin)
  grobX(x$children, theta)
}
#' @keywords internal
#' @method grobY absoluteGrob
grobY.absoluteGrob <- function(x, theta) {
  if (!is.null(x$ymin) && theta == "south") return(x$ymin)
  grobY(x$children, theta)
}

#' @keywords internal
#' @method grid.draw absoluteGrob
grid.draw.absoluteGrob <- function(x, recording = TRUE) {
  NextMethod()
}
