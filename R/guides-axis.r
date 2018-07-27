#' Grob for axes
#' @param at ...
#' @param a_position of ticks
#' @param labels at ticks
#' @param a_theme ...
# @param a_position of axis (top, bottom, left or right)
a_guide_axis <- function(at, labels, a_position = "right", a_theme) {
  if (length(at) == 0)
    return(a_zeroGrob())

  at <- unit(at, "native")
  a_position <- match.arg(a_position, c("top", "bottom", "right", "left"))

  zero <- unit(0, "npc")
  one <- unit(1, "npc")

  label_render <- switch(a_position,
    top = , bottom = "axis.text.x",
    left = , right = "axis.text.y"
  )

  label_x <- switch(a_position,
    top = ,
    bottom = at,
    right = a_theme$axis.ticks.length,
    left = one - a_theme$axis.ticks.length
  )
  label_y <- switch(a_position,
    top = a_theme$axis.ticks.length,
    bottom = one - a_theme$axis.ticks.length,
    right = ,
    left = at
  )

  if (is.list(labels)) {
    if (any(sapply(labels, is.language))) {
      labels <- do.call(expression, labels)
    } else {
      labels <- unlist(labels)
    }
  }

  labels <- switch(a_position,
    top = ,
    bottom = a_element_render(a_theme, label_render, labels, x = label_x, expand_y = TRUE),
    right = ,
    left =  a_element_render(a_theme, label_render, labels, y = label_y, expand_x = TRUE))

  line <- switch(a_position,
    top =    a_element_render(a_theme, "axis.line.x", c(0, 1), c(0, 0), id.lengths = 2),
    bottom = a_element_render(a_theme, "axis.line.x", c(0, 1), c(1, 1), id.lengths = 2),
    right =  a_element_render(a_theme, "axis.line.y", c(0, 0), c(0, 1), id.lengths = 2),
    left =   a_element_render(a_theme, "axis.line.y", c(1, 1), c(0, 1), id.lengths = 2)
  )

  nticks <- length(at)

  ticks <- switch(a_position,
    top = a_element_render(a_theme, "axis.ticks.x",
      x          = rep(at, each = 2),
      y          = rep(unit.c(zero, a_theme$axis.ticks.length), nticks),
      id.lengths = rep(2, nticks)),
    bottom = a_element_render(a_theme, "axis.ticks.x",
      x          = rep(at, each = 2),
      y          = rep(unit.c(one - a_theme$axis.ticks.length, one), nticks),
      id.lengths = rep(2, nticks)),
    right = a_element_render(a_theme, "axis.ticks.y",
      x          = rep(unit.c(zero, a_theme$axis.ticks.length), nticks),
      y          = rep(at, each = 2),
      id.lengths = rep(2, nticks)),
    left = a_element_render(a_theme, "axis.ticks.y",
      x          = rep(unit.c(one - a_theme$axis.ticks.length, one), nticks),
      y          = rep(at, each = 2),
      id.lengths = rep(2, nticks))
  )

  # Create the gtable for the ticks + labels
  gt <- switch(a_position,
    top    = gtable_col("axis",
      grobs   = list(labels, ticks),
      width   = one,
      heights = unit.c(grobHeight(labels), a_theme$axis.ticks.length)
    ),
    bottom = gtable_col("axis",
      grobs   = list(ticks, labels),
      width   = one,
      heights = unit.c(a_theme$axis.ticks.length, grobHeight(labels))
    ),
    right  = gtable_row("axis",
      grobs   = list(ticks, labels),
      widths  = unit.c(a_theme$axis.ticks.length, grobWidth(labels)),
      height  = one
    ),
    left   = gtable_row("axis",
      grobs   = list(labels, ticks),
      widths  = unit.c(grobWidth(labels), a_theme$axis.ticks.length),
      height  = one
    )
  )

  # Viewport for justifying the axis grob
  justvp <- switch(a_position,
    top    = viewport(y = 0, just = "bottom", height = gtable_height(gt)),
    bottom = viewport(y = 1, just = "top",    height = gtable_height(gt)),
    right  = viewport(x = 0, just = "left",   width  = gtable_width(gt)),
    left   = viewport(x = 1, just = "right",  width  = gtable_width(gt))
  )

  absoluteGrob(
    gList(line, gt),
    width = gtable_width(gt),
    height = gtable_height(gt),
    vp = justvp
  )
}
