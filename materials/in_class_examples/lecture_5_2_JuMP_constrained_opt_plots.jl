using JuMP # We need JuMP to declare models
using Ipopt #  and will use Ipopt as the solver

using Plots # To plot stuff
using LaTeXStrings # To print nice math characters in the plot

# Define the objective function
f(x1,x2) = -exp(-(x1*x2 - 3/2)^2 - (x2-3/2)^2);

### MODEL 1

# Initialize model 1
model1 = Model(Ipopt.Optimizer)

# Declare variables
@variable(model1, x1 >= 0)
@variable(model1, x2 >= 0)

# Declare register our function within the model but let autodiff calculate the derivatives
register(model1, :f, 2, f, autodiff = true) # This is just to avoid the warning
@NLobjective(model1, Min, f(x1, x2))

# Print model
print(model1)

# Solve the model
optimize!(model1)

# Collect solution info
unc_obj = objective_value(model1)
unc_x1 = value(x1)
unc_x2 = value(x2)


# Plot solution to model 1

# Generate a grid of points
grid_pts=0:0.01:3.5

# Generate a contour plot (the numbers here are parameters to make the graph look "nice". I found them
# pretty much by trial and error)
p1 = contour(
    grid_pts, # Grid in X
    grid_pts, # Grid in Y
    (x,y)->f(x,y), # This maps values of x and y into our f function to generate values of Z
    lw=1.5, # Define width of countour lines
    levels=collect(0:-0.1:-1.0), # Define with levels should be plotted
    xlab = L"x_1", # X axis label. The leading L tells Julia the string is in LaTeX
    ylab = L"x_2") # Y axis label

# Add a point with the solution and its label
scatter!(
    p1, # Adding to graph p1. Note the !, it means we modify graph p1 by adding a scatter plot on top 
    [unc_x1], # X coordinate of solution
    [unc_x2], # Y coordinate of solution
    markersize=5, # Make it a big point
    markercolor=:red, # Make it a red point
    label="Unc. Optimum") # Label it

savefig(p1, "jump_ex1.png") # Export the plot to a file


# Add a constraint to model 1 and solve it again
@NLconstraint(model1, c1, x1 - x2^2 == 0)
optimize!(model1)
termination_status(model1) # If it's LOCALLY_SOLVED, good!

# Collect solution values
eqcon_x1 = value(x1)
eqcon_x2 = value(x2)
eqcon_obj = objective_value(model1)

# We can also use value to calculate expressions based on the variables
value(x1 - x2^2)

# And we can get the shadow price (or dual value) of constraints like this
dual(c1)

# Plot model 1 with the equality constraint

# Define the curve for the equality restriction
c(z) = sqrt(z)

# Add that curve to p1 (the original contour plot)
plot!(p1,
    c, # Tells julia to plot this function
    0.01, # Between x1 = 0
    3.5, # Until x1 = 3.5
    label="", # Don't label it
    lw=2, # Set line tickness
    color=:black) # And color the line black

# Add the second solution point to plot p1
scatter!(p1,
    [eqcon_x1], # Coordinate X
    [eqcon_x2], # Coordinate Y
    markersize=5,
    markercolor=:blue,
    label="Equality constr. optimum")

# Export the plot    
savefig(p1, "jump_ex2.png")

### MODEL 2

# Define model 2 into JuMP
model2 = Model(Ipopt.Optimizer)
@variable(model2, x1 >=0)
@variable(model2, x2 >=0)
register(model2, :f, 2, f, autodiff = true) # Again, just to avoid the warning
@NLobjective(model2, Min, f(x1, x2))
@NLconstraint(model2, c1, -x1 + x2^2 <= 0)

# Solve
optimize!(model2)

# Collect solution info
ineqcon_obj = objective_value(model2)
ineqcon_x1 = value(x1)
ineqcon_x2 = value(x2)

# Make a new contour plot
p2 = contour(
    grid_pts, # Grid in X
    grid_pts, # Grid in Y
    (x,y)->f(x,y), # This maps values of x and y into our f function to generate values of Z
    lw=1.5, # Define width of countour lines
    levels=collect(0:-0.1:-1.0), # Define with levels should be plotted
    xlab = L"x_1", # X axis label. The leading L tells Julia the string is in LaTeX
    ylab = L"x_2") # Y axis label    

# Add a point with the solution and its label
plot!(p2,
    c, # Tells julia to plot this function
    0.01, # Between x1 = 0
    3.5, # Until x1 = 3.5
    label="", # Don't label it
    lw=2, # Set line tickness
    color=:black, # Color the line black
    fill=(0,0.2,:blue)) # And fill the region with opacity 0.2 and color blue

# Add the solution point (parameters are the same as in model 1)
scatter!(p2,
    [ineqcon_x1],
    [ineqcon_x2],
    markersize=5,
    markercolor=:blue,
    label="Binding inequality constr. optimum")

# And save the new model plot
savefig(p2, "jump_ex3.png")


### MODEL 3

# Declare and solve it
model3 = Model(Ipopt.Optimizer)
@variable(model3, x1 >=0)
@variable(model3, x2 >=0)
register(model3, :f, 2, f, autodiff = true) # Again, just to avoid the warning
@NLobjective(model3, Min, f(x1, x2))
@NLconstraint(model3, c1, -x1 + x2^2 <= 1.5)
optimize!(model3)

ineqcon2_obj = objective_value(model3)
ineqcon2_x1 = value(x1)
ineqcon2_x2 = value(x2)


# Define the new constraint equation to draw
c_inactive(z) = sqrt(z) + 1.5

# Plot new constraint into p2
plot!(p2,
    c_inactive, # New contraint function
    0.01, # From this value
    3.5, # To this value
    label="", # No label
    lw=2,
    color=:black,
    fill=(0,0.1,:red)) # Fill the area with red and opacity 0.1

# Add the solution point    
scatter!(p2,
    [ineqcon2_x1],
    [ineqcon2_x2],
    markersize=5,
    markercolor=:red,
    label="Slack inequality constr. optimum")
    
# Save the final plot    
savefig(p2, "jump_ex4.png")