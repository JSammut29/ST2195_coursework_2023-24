library(ggplot2)
library(gganimate)
library(gifski)
library(dplyr)

library(rmarkdown)
#setwd("C:/Users/josmi/Desktop/University of London/Programming for Data Science ST2195/ST2195_coursework_2023-24")
set.seed(123)  # Used to generate figures, for reproducibility.
render("Random_Walk_Metropolis.Rmd")

# Function to create a GIF of samples over iterations
create_iteration_gif <- function(samples, steps = c(10, seq(100, 1000, by = 100), 2500, 5000, 10000)) {
  # Create a data frame for plotting cumulative samples
  plot_data <- data.frame(
    sample_value = unlist(lapply(steps, function(x) samples[1:x])),
    iteration = rep(steps, times = steps)
  )
  
  # Create the plot
  p <- ggplot(plot_data, aes(x = sample_value)) +
    geom_histogram(aes(y = after_stat(density)), bins = 50, fill = 'lightblue', alpha = 0.7) +
    geom_density(color = 'blue') +
    stat_function(fun = f, color = 'red', linewidth = 1) +
    labs(title = 'Iteration: {closest_state}', x = 'Sample Value', y = 'Density') +
    theme_minimal() +
    transition_states(iteration, transition_length = 2, state_length = 1, wrap = FALSE) +
    ease_aes('linear')
  
  # Save the animation as a GIF using gifski_renderer
  anim <- animate(p, nframes = length(steps), fps = 2, width = 800, height = 600, renderer = gifski_renderer())
  anim_save("metropolis_iterations.gif", animation = anim)
}

# Create GIF
samples <- metropolis_hastings(N = 10000, s = 1, x0 = 0)
create_iteration_gif(samples)