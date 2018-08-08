#' Update axis/legend labels
#'
#' @param p plot to modify
#' @param a_labels named list of new labels
#' @export
#' @examples
#' p <- a_plot(mtcars, a_aes(mpg, wt)) + a_geom_point()
#' update_a_labels(p, list(x = "New x"))
#' update_a_labels(p, list(x = expression(x / y ^ 2)))
#' update_a_labels(p, list(x = "New x", y = "New Y"))
#' update_a_labels(p, list(colour = "Fail silently"))
update_a_labels <- function(p, a_labels) {
  p <- a_plot_clone(p)
  p$a_labels <- defaults(a_labels, p$a_labels)
  p
}

#' Change axis a_labels, legend titles, plot title/subtitle and below-plot
#' caption.
#'
#' @param a_label The text for the axis, plot title or caption below the plot.
#' @param subtitle the text for the subtitle for the plot which will be
#'        displayed below the title. Leave \code{NULL} for no subtitle.
#' @param ... a list of new names in the form a_aesthetic = "new name"
#' @keywords internal
#' @examples
#' p <- a_plot(mtcars, a_aes(mpg, wt)) + a_geom_point()
#' p + ggplot2Animint:::labs(title = "New plot title")
#' p + ggplot2Animint:::labs(x = "New x a_label")
#' p + xlab("New x a_label")
#' p + ylab("New y a_label")
#' p + ggtitle("New plot title")
#'
#' # Can add a subtitle to plots with either of the following
#' p + ggtitle("New plot title", subtitle = "A subtitle")
#' p + ggplot2Animint:::labs(title = "New plot title", subtitle = "A subtitle")
#'
#' # Can add a plot caption underneath the whole plot (for sources, notes or
#' # copyright), similar to the \code{sub} parameter in base R, with the
#' # following
#' p + ggplot2Animint:::labs(caption = "(based on data from ...)")
#'
#' # This should work independently of other functions that modify the
#' # the scale names
#' p + ylab("New y a_label") + ylim(2, 4)
#' p + ylim(2, 4) + ylab("New y a_label")
#'
#' # The labs function also modifies legend a_labels
#' p <- a_plot(mtcars, a_aes(mpg, wt, colour = cyl)) + a_geom_point()
#' p + ggplot2Animint:::labs(colour = "Cylinders")
#'
#' # Can also pass in a list, if that is more convenient
#' p + ggplot2Animint:::labs(list(title = "Title", subtitle = "Subtitle", x = "X", y = "Y"))
labs <- function(...) {
  args <- list(...)
  if (is.list(args[[1]])) args <- args[[1]]
  args <- rename_aes(args)
  structure(args, class = "a_labels")
}

#' @rdname labs
#' @export
xlab <- function(a_label) {
  labs(x = a_label)
}

#' @rdname labs
#' @export
ylab <- function(a_label) {
  labs(y = a_label)
}

#' @rdname labs
#' @export
ggtitle <- function(a_label, subtitle = NULL) {
  labs(title = a_label, subtitle = subtitle)
}

# Convert aesthetic mapping into text a_labels
make_labels <- function(mapping) {
  remove_dots <- function(x) {
    gsub(match_calculated_aes, "\\1", x)
  }

  default_label <- function(a_aesthetic, mapping) {
    # e.g., a_geom_smooth(a_aes(colour = "loess"))
    if (is.character(mapping)) {
      a_aesthetic
    } else {
      remove_dots(deparse(mapping))
    }
  }
  Map(default_label, names(mapping), mapping)
}
