#' Calculation for quantile-quantile plot.
#'
#' @section Aesthetics:
#' \Sexpr[results=rd,stage=build]{ggplot2Animint:::rd_aesthetics("a_stat", "qq")}
#'
#' @param distribution Distribution function to use, if x not specified
#' @param dparams Additional parameters passed on to \code{distribution}
#'   function.
#' @inheritParams layer
#' @inheritParams a_geom_point
#' @section Computed variables:
#' \describe{
#'   \item{sample}{sample quantiles}
#'   \item{theoretical}{theoretical quantiles}
#' }
#' @export
#' @examples
#' \donttest{
#' df <- data.frame(y = rt(200, df = 5))
#' p <- a_plot(df, aes(sample = y))
#' p + a_stat_qq()
#' p + a_geom_point(a_stat = "qq")
#'
#' # Use fitdistr from MASS to estimate distribution params
#' params <- as.list(MASS::fitdistr(df$y, "t")$estimate)
#' a_plot(df, aes(sample = y)) +
#'   a_stat_qq(distribution = qt, dparams = params["df"])
#'
#' # Using to explore the distribution of a variable
#' a_plot(mtcars) +
#'   a_stat_qq(aes(sample = mpg))
#' a_plot(mtcars) +
#'   a_stat_qq(aes(sample = mpg, colour = factor(cyl)))
#' }
a_stat_qq <- function(mapping = NULL, data = NULL,
                    a_geom = "point", position = "identity",
                    ...,
                    distribution = stats::qnorm,
                    dparams = list(),
                    na.rm = FALSE,
                    show.legend = NA,
                    inherit.aes = TRUE) {
  layer(
    data = data,
    mapping = mapping,
    a_stat = a_StatQq,
    a_geom = a_geom,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      distribution = distribution,
      dparams = dparams,
      na.rm = na.rm,
      ...
    )
  )
}

#' @export
#' @rdname a_stat_qq
a_geom_qq <- a_stat_qq

#' @rdname ggplot2Animint-ggproto
#' @format NULL
#' @usage NULL
#' @export
a_StatQq <- a_ggproto("a_StatQq", a_Stat,
  default_aes = aes(y = ..sample.., x = ..theoretical..),

  required_aes = c("sample"),

  compute_group = function(data, scales, quantiles = NULL,
                           distribution = stats::qnorm, dparams = list(),
                           na.rm = FALSE) {

    sample <- sort(data$sample)
    n <- length(sample)

    # Compute theoretical quantiles
    if (is.null(quantiles)) {
      quantiles <- stats::ppoints(n)
    } else {
      stopifnot(length(quantiles) == n)
    }

    theoretical <- do.call(distribution, c(list(p = quote(quantiles)), dparams))

    data.frame(sample, theoretical)
  }
)
