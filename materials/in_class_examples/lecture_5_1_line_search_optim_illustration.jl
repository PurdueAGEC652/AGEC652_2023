using Optim, Plots, LineSearches, LinearAlgebra;

### Setup ###

# Define the illustration function
a = 1; b = 4; c = -2; d = -1; e = -3
f(x) = a*x[1]^2 + b*x[2]^2 + c*x[1] + d*x[2] + e*x[1]*x[2]

# Plot level curves of this figure (contour plot)
# First, it is best to make levels in log scale for a better plot
# The levels go from -5 (the approximate minimum) to 500 (the approximate maximum)
curve_levels = exp.(0:log(1.2):log(500)) .- 5

# Generate a contour plot with a grid from -5 to 10 along both axes
# Since our f takes in a vector, we need to create an anonymous wrapper function that
# takes in x and y separately (countour requires that). This is done with (x,y)->f([x, y])
Plots.contour(-5.0:0.1:10.0, -5:0.1:10.0, (x,y)->f([x, y]), fill = true, levels = curve_levels)


# Define the gradient and Hessian functions
function g!(G, x)
    G[1] = 2a*x[1] + c + e*x[2]
    G[2] = 2b*x[2] + d + e*x[1]
end
function h!(H, x)
    H[1,1] = 2a
    H[1,2] = e
    H[2,1] = e
    H[2,2] = 2b
end 

# Test whether H is positive definite
H = zeros(2,2)
h!(H, [0 0]);
LinearAlgebra.eigen(H).values

# Calculate analytic solution
# (Since the function is quadratic, the FOC is a linear system)
analytic_x_star = [2a e; e 2b]\[-c ;-d]


### Perform numeric optimization ###

# 1. Optimization with Gradient Descent
# (We use extended_trace option to store all the intermediate guesses)
x0 = [0.2, 1.6] # Initial guess
res_GD = Optim.optimize(f, g!, x0,
                        GradientDescent(),
                        Optim.Options(store_trace=true, extended_trace=true, x_abstol=1e-3))

# Read and store the intermediate guesses in a N x 2 matrix
guesses_GD = hcat(Optim.x_trace(res_GD)...)'

# Plot solution
# Set axes limits and grids
x_lims = (0.0, 3.0)
y_lims = (0.0, 2.0)
x_grid = collect(range(x_lims[1], x_lims[2], step = 0.01))
y_grid = collect(range(y_lims[1], y_lims[2], step = 0.01))

# Make non-filled contour plot
contour(x_grid, y_grid, (x,y)->f([x, y]), fill = false, levels = curve_levels)

# Add line trajectory
plot!(guesses_GD[:, 1], guesses_GD[:, 2], xlim=x_lims, ylim=y_lims, color =:red, label = "Gradient Descent")
# Then points
GD_plot = scatter!(guesses_GD[:, 1], guesses_GD[:, 2],  xlim=x_lims, ylim=y_lims, color =:red, label = "")


## 2. Gradient Descent with BackTracking
# Solve it
res_GDBT = Optim.optimize(f, g!, x0,
                         GradientDescent(alphaguess = LineSearches.InitialStatic(alpha = 1.0),
                                         linesearch = BackTracking()),
                         Optim.Options(store_trace=true, extended_trace=true, x_abstol=1e-3))

# Collect guesses
guesses_GDBT = hcat(Optim.x_trace(res_GDBT)...)'

# Plot solution
plot!(guesses_GDBT[:, 1], guesses_GDBT[:, 2], xlim=x_lims, ylim=y_lims, color =:orange, label = "Gradient Descent + BackTracking")
GDBT_plot =scatter!(guesses_GDBT[:, 1], guesses_GDBT[:, 2],  xlim=x_lims, ylim=y_lims, color =:orange, label = "")



# 3. Newton-Raphson
# Solve it
res_NR = Optim.optimize(f, g!, h!, x0,
                        Newton(),
                        Optim.Options(store_trace=true, extended_trace=true, x_abstol=1e-4))

# Collect guesses
guesses_NR = hcat(Optim.x_trace(res_NR)...)'

# Plot solution
plot!(guesses_NR[:, 1], guesses_NR[:, 2], xlim=x_lims, ylim=y_lims, color =:blue, label = "Newton-Raphson")
NR_plot = scatter!(guesses_NR[:, 1], guesses_NR[:, 2],  xlim=x_lims, ylim=y_lims, color =:blue, label = "")


# 4. BFGS

# Solve it
res_BFGS = Optim.optimize(f, x0,
                          BFGS(),
                          Optim.Options(store_trace=true, extended_trace=true, x_abstol=1e-4))

# Collect guesses
guesses_BFGS = hcat(Optim.x_trace(res_BFGS)...)'

# Plot solution
plot!(guesses_BFGS[:, 1], guesses_BFGS[:, 2], xlim=x_lims, ylim=y_lims, color =:green, label = "BFGS")
BFGS_plot = scatter!(guesses_BFGS[:, 1], guesses_BFGS[:, 2],  xlim=x_lims, ylim=y_lims, color =:green, label = "")

# 5. Trust region
# Solve it
res_NTR = Optim.optimize(f, g!, h!, x0,
                         NewtonTrustRegion(),
                         Optim.Options(store_trace=true, extended_trace=true, x_abstol=1e-4))

# Collect guesses
guesses_NTR = hcat(Optim.x_trace(res_NTR)...)'

# Plot solution
plot!(guesses_NTR[:, 1], guesses_NTR[:, 2], xlim=x_lims, ylim=y_lims, color =:gray, label = "Newton Trust Region")
NTR_plot = scatter!(guesses_NTR[:, 1], guesses_NTR[:, 2],  xlim=x_lims, ylim=y_lims, color =:gray, label = "")

# Save combined plots
savefig(NTR_plot, "My_optimization_plot.png")
