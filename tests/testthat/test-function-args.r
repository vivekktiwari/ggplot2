context("function-args")

filter_args <- function(x) {
  all_names <- names(x)
  all_names <- setdiff(all_names, c("self", "data", "scales", "coordinates", "..."))
  x[all_names]
}

test_that("geom_xxx and GeomXxx$draw arg defaults match", {
  ggplot2_ns <- asNamespace("ggplot2Animint")
  objs <- ls(ggplot2_ns)
  a_geom_fun_names <- objs[grepl("^(a_geom|annotation)_", objs)]
  # These aren't actually geoms, or need special parameters and can't be tested this way.
  a_geom_fun_names <- setdiff(
    a_geom_fun_names,
    c("a_geom_aesthetics", "a_geom_map", "annotation_custom", "annotation_map",
      "annotation_raster", "annotation_id")
  )

  # For each geom_xxx function and the corresponding GeomXxx$draw and
  # GeomXxx$draw_groups functions, make sure that if they have same args, that
  # the args have the same default values.
  lapply(a_geom_fun_names, function(a_geom_fun_name) {
    a_geom_fun    <- ggplot2_ns[[a_geom_fun_name]]
    draw        <- a_geom_fun()$a_geom$draw_layer
    draw_groups <- a_geom_fun()$a_geom$draw_group

    fun_args <- formals(a_geom_fun)
    draw_args <- c(a_ggproto_formals(draw), a_ggproto_formals(draw_groups))
    draw_args <- filter_args(draw_args)

    common_names <- intersect(names(fun_args), names(draw_args))

    expect_identical(fun_args[common_names], draw_args[common_names],
      info = paste0("Mismatch between arg defaults for ", a_geom_fun_name,
        " and ", class(a_geom_fun()$a_geom)[1], "'s $draw and/or $draw_group functions.")
    )
  })
})


test_that("stat_xxx and StatXxx$draw arg defaults match", {
  ggplot2_ns <- asNamespace("ggplot2Animint")
  objs <- ls(ggplot2_ns)
  stat_fun_names <- objs[grepl("^stat_", objs)]
  # These aren't actually stats, or need special parameters and can't be tested this way.
  stat_fun_names <- setdiff(
    stat_fun_names,
    c("stat_aesthetics", "stat_function")
  )

  # For each a_geom_xxx function and the corresponding GeomXxx$draw and
  # GeomXxx$draw_groups functions, make sure that if they have same args, that
  # the args have the same default values.
  lapply(stat_fun_names, function(stat_fun_name) {
    stat_fun         <- ggplot2_ns[[stat_fun_name]]
    calculate        <- stat_fun()$stat$compute
    calculate_groups <- stat_fun()$stat$compute_group

    fun_args <- formals(stat_fun)
    calc_args <- c(a_ggproto_formals(calculate), a_ggproto_formals(calculate_groups))
    calc_args <- filter_args(calc_args)

    common_names <- intersect(names(fun_args), names(calc_args))

    expect_identical(fun_args[common_names], calc_args[common_names],
      info = paste0("Mismatch between arg defaults for ", stat_fun_name,
        " and ", class(stat_fun()$stat)[1], "'s $compute and/or $compute_groups functions.")
    )
  })
})
