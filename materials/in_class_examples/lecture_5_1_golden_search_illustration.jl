function golden_search(f, lo, up)
    alpha_1 = (3 - sqrt(5))/2  # GS parameter 1
    alpha_2 = (sqrt(5) - 1)/2  # GS parameter 2
    tolerance = 1e-3      # tolerance for convergence
    mid = (lo + up)/2     # initialize guess 
    difference = Inf      # initialize bound difference
    
    guesses = [mid] # Initialize a vector with guesses

    while difference > tolerance      # loop until convergence
        x_1 = lo + alpha_1*(up - lo)  # new x_1
        x_2 = lo + alpha_2*(up - lo)  # new x_2
        if f(x_1) < f(x_2)            # reset bounds
            up = x_2
        else
            lo = x_1
        end
        difference = x_2 - x_1  # update diffence
        mid = (lo + up)/2     # update guess
        push!(guesses, mid)     # store new guess at the end of the vector
    end
    return guesses # Return all guesses with the solution being the last element
end;

# Define our function
f(x) = 2x^2 - 4x

# Find root and store guesses 
guesses = golden_search(f, -4, 4)

# Plot function between 0.2 and 4 with a fine grid
using Plots;
grid = collect(-4: 0.01:4);
ys = f.(grid);
gr();
plt = plot(
    grid, # horizontal axis
    ys,   # vertical axis
    label = "" # omit legend
)

# for each guess, add a scatter point at at time
anim = @animate for i=1:length(guesses)
    if (i <= 6) # for the first iterations, we keep the original limits
        scatter!([guesses[i]], [f(guesses[i])], label = "");
    elseif (i <= 12) # for later iterations, we change the limits to zoom in
        scatter!([guesses[i]], [f(guesses[i])], xlim = (0, 2), ylim = (-4, 0), label = "");
    else
        scatter!([guesses[i]], [f(guesses[i])], xlim = (0.7, 1.3), ylim = (-3, -1), label = "");
    end
end

# save the sequence as a gif
gif(anim, fps = 1, "golden_search.gif")



