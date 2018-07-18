#' @section a_Stats:
#'
#' All \code{a_stat_*} functions (like \code{a_stat_bin}) return a layer that
#' contains a \code{a_Stat*} object (like \code{a_StatBin}). The \code{a_Stat*}
#' object is responsible for rendering the data in the plot.
#'
#' Each of the \code{a_Stat*} objects is a \code{\link{a_ggproto}} object, descended
#' from the top-level \code{a_Stat}, and each implements various methods and
#' fields. To create a new type of Stat object, you typically will want to
#' implement one or more of the following:
#'
#' \itemize{
#'   \item Override one of :
#'     \code{compute_layer(self, data, scales, ...)},
#'     \code{compute_panel(self, data, scales, ...)}, or
#'     \code{compute_group(self, data, scales, ...)}.
#'
#'     \code{compute_layer()} is called once per layer, \code{compute_panel_()}
#'     is called once per panel, and \code{compute_group()} is called once per
#'     group. All must return a data frame.
#'
#'     It's usually best to start by overriding \code{compute_group}: if
#'     you find substantial performance optimisations, override higher up.
#'     You'll need to read the source code of the default methods to see
#'     what else you should be doing.
#'
#'     \code{data} is a data frame containing the variables named according
#'     to the aesthetics that they're mapped to. \code{scales} is a list
#'     containing the \code{x} and \code{y} scales. There functions are called
#'     before the facets are trained, so they are global scales, not local
#'     to the individual panels.\code{...} contains the parameters returned by
#'     \code{setup_params()}.
#'   \item \code{setup_params(data, params)}: called once for each layer.
#'      Used to setup defaults that need to complete dataset, and to inform
#'      the user of important choices. Should return list of parameters.
#'   \item \code{setup_data(data, params)}: called once for each layer,
#'      after \code{setp_params()}. Should return modified \code{data}.
#'      Default methods removes all rows containing a missing value in
#'      required aesthetics (with a warning if \code{!na.rm}).
#'   \item \code{required_aes}: A character vector of aesthetics needed to
#'     render the geom.
#'   \item \code{default_aes}: A list (generated by \code{\link{aes}()} of
#'     default values for aesthetics.
#' }
#' @rdname ggplot2Animint-ggproto
#' @format NULL
#' @usage NULL
#' @export
a_Stat <- a_ggproto("a_Stat",
  # Should the values produced by the statistic also be transformed
  # in the second pass when recently added statistics are trained to
  # the scales
  retransform = TRUE,

  default_aes = aes(),

  required_aes = character(),

  non_missing_aes = character(),

  setup_params = function(data, params) {
    params
  },

  setup_data = function(data, params) {
    data
  },

  compute_layer = function(self, data, params, panels) {
    check_required_aesthetics(
      self$a_stat$required_aes,
      c(names(data), names(params)),
      snake_class(self$a_stat)
    )

    data <- remove_missing(data, params$na.rm,
      c(self$required_aes, self$non_missing_aes),
      snake_class(self),
      finite = TRUE
    )

    # Trim off extra parameters
    params <- params[intersect(names(params), self$parameters())]

    args <- c(list(data = quote(data), scales = quote(scales)), params)
    plyr::ddply(data, "PANEL", function(data) {
      scales <- panel_scales(panels, data$PANEL[1])
      tryCatch(do.call(self$compute_panel, args), error = function(e) {
        warning("Computation failed in `", snake_class(self), "()`:\n",
          e$message, call. = FALSE)
        data.frame()
      })
    })
  },

  compute_panel = function(self, data, scales, ...) {
    if (empty(data)) return(data.frame())

    groups <- split(data, data$group)
    stats <- lapply(groups, function(group) {
      self$compute_group(data = group, scales = scales, ...)
    })

    stats <- mapply(function(new, old) {
      if (empty(new)) return(data.frame())
      unique <- uniquecols(old)
      missing <- !(names(unique) %in% names(new))
      cbind(
        new,
        unique[rep(1, nrow(new)), missing,drop = FALSE]
      )
    }, stats, groups, SIMPLIFY = FALSE)

    do.call(plyr::rbind.fill, stats)
  },

  compute_group = function(self, data, scales) {
    stop("Not implemented", call. = FALSE)
  },


  # See discussion at Geom$parameters()
  extra_params = "na.rm",
  parameters = function(self, extra = FALSE) {
    # Look first in compute_panel. If it contains ... then look in compute_group
    panel_args <- names(a_ggproto_formals(self$compute_panel))
    group_args <- names(a_ggproto_formals(self$compute_group))
    args <- if ("..." %in% panel_args) group_args else panel_args

    # Remove arguments of defaults
    args <- setdiff(args, names(a_ggproto_formals(a_Stat$compute_group)))

    if (extra) {
      args <- union(args, self$extra_params)
    }
    args
  }
)
