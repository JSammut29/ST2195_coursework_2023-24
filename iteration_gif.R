library(ggplot2)
library(gganimate)

library(rmarkdown)
#setwd("C:/Users/josmi/Desktop/University of London/Programming for Data Science ST2195/ST2195_coursework_2023-24")
render("Random_Walk_Metropolis.Rmd")

# Function to create a GIF of samples over iterations
create_iteration_gif <- function(samples) {
  iterations <- seq(1, length(samples), by = 100)
  
  # Create a data frame for plotting
  plot_data <- data.frame(
    iteration = rep(iterations, each = 100),
    sample_value = rep(samples[iterations], each = 100)
  )
  
  # Create the plot
  p <- ggplot(plot_data, aes(x = sample_value)) +
    geom_histogram(aes(y = ..density..), bins = 30, fill = 'lightblue', alpha = 0.7) +
    stat_function(fun = f, color = 'red', size = 1) +
    labs(title = 'Iteration: {frame_along}', x = 'Sample Value', y = 'Density') +
    theme_minimal() +
    transition_states(iteration, transition_length = 2, state_length = 1)
  
  # Save the animation as a GIF
  anim <- animate(p, nframes = length(iterations), fps = 10, width = 800, height = 600)
  anim_save("metropolis_iterations.gif", animation = anim)
}

# Call the function with the generated samples
create_iteration_gif(samples)
