#' Don't adjust position
#'
#' @family position adjustments
#' @export
position_identity <- function() {
  a_PositionIdentity
}

#' @rdname ggplot2-ggproto
#' @format NULL
#' @usage NULL
#' @export
a_PositionIdentity <- ggproto("a_PositionIdentity", a_Position,
  compute_layer = function(data, params, scales) {
    data
  }
)
