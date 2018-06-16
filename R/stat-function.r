#' Superimpose a function.
#'
#' @section Aesthetics:
#' \Sexpr[results=rd,stage=build]{ggplot2Animint:::rd_aesthetics("a_stat", "function")}
#'
#' @param fun function to use
#' @param n number of points to interpolate along
#' @param args list of additional arguments to pass to \code{fun}
#' @param xlim Optionally, restrict the range of the function to this range.
#' @inheritParams layer
#' @inheritParams geom_point
#' @section Computed variables:
#' \describe{
#'   \item{x}{x's along a grid}
#'   \item{y}{value of function evaluated at corresponding x}
#' }
#' @export
#' @examples
#' set.seed(1492)
#' df <- data.frame(
#'   x = rnorm(100)
#' )
#' x <- df$x
#' base <- a_plot(df, aes(x)) + geom_density()
#' base + stat_function(fun = dnorm, colour = "red")
#' base + stat_function(fun = dnorm, colour = "red", args = list(mean = 3))
#'
#' # Plot functions without data
#' # Examples adapted from Kohske Takahashi
#'
#' # Specify range of x-axis
#' a_plot(data.frame(x = c(0, 2)), aes(x)) +
#'   stat_function(fun = exp, geom = "line")
#'
#' # Plot a normal curve
#' a_plot(data.frame(x = c(-5, 5)), aes(x)) + stat_function(fun = dnorm)
#'
#' # To specify a different mean or sd, use the args parameter to supply new values
#' a_plot(data.frame(x = c(-5, 5)), aes(x)) +
#'   stat_function(fun = dnorm, args = list(mean = 2, sd = .5))
#'
#' # Two functions on the same plot
#' f <- a_plot(data.frame(x = c(0, 10)), aes(x))
#' f + stat_function(fun = sin, colour = "red") +
#'   stat_function(fun = cos, colour = "blue")
#'
#' # Using a custom function
#' test <- function(x) {x ^ 2 + x + 20}
#' f + stat_function(fun = test)
stat_function <- function(mapping = NULL, data = NULL,
                          geom = "path", position = "identity",
                          ...,
                          fun,
                          xlim = NULL,
                          n = 101,
                          args = list(),
                          na.rm = FALSE,
                          show.legend = NA,
                          inherit.aes = TRUE) {
  layer(
    data = data,
    mapping = mapping,
    stat = a_StatFunction,
    geom = geom,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      fun = fun,
      n = n,
      args = args,
      na.rm = na.rm,
      xlim = xlim,
      ...
    )
  )
}

#' @rdname ggplot2-ggproto
#' @format NULL
#' @usage NULL
#' @export
a_StatFunction <- ggproto("a_StatFunction", a_Stat,
  default_aes = aes(y = ..y..),

  compute_group = function(data, scales, fun, xlim = NULL, n = 101, args = list()) {
    range <- xlim %||% scales$x$dimension()
    xseq <- seq(range[1], range[2], length.out = n)

    if (scales$x$is_discrete()) {
      x_trans <- xseq
    } else {
      # For continuous scales, need to back transform from transformed range
      # to original values
      x_trans <- scales$x$trans$inverse(xseq)
    }

    data.frame(
      x = xseq,
      y = do.call(fun, c(list(quote(x_trans)), args))
    )
  }
)
