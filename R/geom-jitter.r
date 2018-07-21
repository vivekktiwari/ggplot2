#' Points, jittered to reduce overplotting.
#'
#' The jitter geom is a convenient default for a_geom_point with position =
#' 'jitter'. It's a useful way of handling overplotting caused by discreteness
#' in smaller datasets.
#'
#' @section Aesthetics:
#' \Sexpr[results=rd,stage=build]{ggplot2Animint:::rd_aesthetics("a_geom", "point")}
#'
#' @inheritParams layer
#' @inheritParams a_geom_point
#' @inheritParams position_jitter
#' @seealso
#'  \code{\link{a_geom_point}} for regular, unjittered points,
#'  \code{\link{a_geom_boxplot}} for another way of looking at the conditional
#'     distribution of a variable
#' @export
#' @examples
#' p <- a_plot(mpg, aes(cyl, hwy))
#' p + a_geom_point()
#' p + a_geom_jitter()
#'
#' # Add aesthetic mappings
#' p + a_geom_jitter(aes(colour = class))
#'
#' # Use smaller width/height to emphasise categories
#' a_plot(mpg, aes(cyl, hwy)) + a_geom_jitter()
#' a_plot(mpg, aes(cyl, hwy)) + a_geom_jitter(width = 0.25)
#'
#' # Use larger width/height to completely smooth away discreteness
#' a_plot(mpg, aes(cty, hwy)) + a_geom_jitter()
#' a_plot(mpg, aes(cty, hwy)) + a_geom_jitter(width = 0.5, height = 0.5)
a_geom_jitter <- function(mapping = NULL, data = NULL,
                        a_stat = "identity", position = "jitter",
                        ...,
                        width = NULL,
                        height = NULL,
                        na.rm = FALSE,
                        show.legend = NA,
                        inherit.aes = TRUE) {
  if (!missing(width) || !missing(height)) {
    if (!missing(position)) {
      stop("Specify either `position` or `width`/`height`", call. = FALSE)
    }

    position <- position_jitter(width = width, height = height)
  }

  layer(
    data = data,
    mapping = mapping,
    a_stat = a_stat,
    a_geom = a_GeomPoint,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      na.rm = na.rm,
      ...
    )
  )
}
