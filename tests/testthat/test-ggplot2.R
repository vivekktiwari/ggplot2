context("ggplot2Compatibility")

test_that("animint2 works fine with ggplot2", {
  
  aa <- a_plot(mpg, aes(displ, hwy))
  gg <- ggplot2::ggplot(mpg, aes(displ, hwy))
  
  expect_identical(aa$data, gg$data)
  expect_identical(aa$plot_env, gg$plot_env)
  expect_identical(aa$theme, gg$theme)
  
  l1 <- aa$mapping[1]
  l2 <- gg$mapping[1]
  expect_equal(l1, l2)
  })