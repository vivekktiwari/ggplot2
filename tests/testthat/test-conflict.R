context("Conflicts")

test_that("environment test", {

   t <- environment(stat_summary)
   tt <- environment(ggplot2Animint::stat_summary)
   expect_identical(t, tt)

  })
