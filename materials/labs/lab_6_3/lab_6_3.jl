using JuMP, Ipopt


## PART 1

function solve_c_l(w, e, gamma, tau)
    model = Model(Ipopt.Optimizer)
    # Declare variables
    # <@variable...>

    # Declare objective
    # <@NLobjective...>
    
    # Declare budget constraint
    # <@NLconstraint...>
  
    set_silent(model) # Mute output
    optimize!(model)
    # Warn if error
    if (termination_status(model) != LOCALLY_SOLVED)
        println("Error: row $i, draw $j $(termination_status(model))")
    end
    c = value(c)
    l = value(l)
    return (c, l)

end

# Test it
solve_c_l(80.0, 2.0, 0.5, 0.1)



###################

## PART 2
using Random, Distributions
Random.seed!(65200)

function solve_Ec_El(w, gamma, tau, R)
    model = Model(Ipopt.Optimizer)

    # Declare variables
    # <@variable...>

    # Declare objective
    # <@NLobjective...>

    # Declare epsilon as model parameters
    @NLparameter(model, e == 0.0)
    
    # Declare budget constraint
    # <@NLconstraint...>

    set_silent(model) # Mute output

    # Draw R epsilons
    # <es =...>

    # Initialize vectors to store for individual i
    cs_i = zeros(R)
    ls_i = zeros(R)

    # Loop to simulate
    for i in 1:R
        set_value(e, es[i]) # Set a drawn value for epsilon
        optimize!(model) # Solve it
        
        # Warn if error
        if (termination_status(model) != LOCALLY_SOLVED)
            println("Error in draw $i: $(termination_status(model))")
        end
        
        # Store the solution value of consumption
        # <cs_i[i] = ...>

        # And store the solution value of leisure
        # <ls_i[i] = ...>
    end
   
    # Take average of simulated values and return
    Ec = mean(cs_i)
    El = mean(ls_i)
    return (Ec, El)
end

# Test it
solve_Ec_El(80.0, 0.5, 0.1, 10)

# But this is a random approximation. Test it again
solve_Ec_El(80.0, 0.5, 0.1, 10)


###################

## DATA EXPLORATION

using DataFrames, CSV, Plots

# Load data
df = CSV.read("labor_supply.csv", DataFrame)


# Convert to annual wage rates
df.l = 1 .- (df.labor_hours ./ 3600)

# Plot histogram
plot(histogram(df.labor_hours, label="Labor hours"),  histogram(df.l, label="Leisure index (l)"))

# Redefine consumption to thousand USD (problem scaling!)
df.c = df.consump ./ 1000
histogram(df.c, label="c")


###################

## PART 3

N = nrow(df)

function solve_all_Ec_El(gamma, tau)
    # Vectors to store simulated moments    
    cs = zeros(N)
    ls = zeros(N)
    # Number of MC draws
    R = 20 # Should be more, but we need to solve it before 6 PM!
    # Loop over individuals
    for i in 1:N
        # <cs[i], ls[i] = ... >
    end
    return (cs, ls)
end

@time solve_all_Ec_El(0.4, 0.1)


## Extra: parallel processing
Threads.nthreads()

function parallel_solve_all_Ec_El(gamma, tau)
    # Vectors to store simulated moments    
    cs = zeros(N)
    ls = zeros(N)
    # Number of MC draws
    R = 20 # Should be more, but we need to solve it before 10 AM!
    # Loop over individuals
    Threads.@threads for i in 1:N # <- This is the only difference
        # <cs[i], ls[i] = ... >
    end
    return (cs, ls)
end



###################

## Setting up the MSM

# Momment function
function Q(theta)
    # Transform theta to ensure (0,1) interval
    theta = exp.(theta) ./ (1.0 .+ exp.(theta))
    gamma = theta[1]
    tau = theta[2]
    
    # Calculate predicted cs and ls
    cs, ls = parallel_solve_all_Ec_El(gamma, tau)
    
    # First moment condition: E[c_hat - c]
    M1 = mean(cs - df.c)
    
    # Second moment condition: E[l_hat - l]
    M2 = mean(ls - df.l)
    
    # Calculate Q
    M1^2 + M2^2
end



###################

# Estimate structural parameters
using Optim

# Initial guess
theta_0 = [0.0, log(0.14)];
exp.(theta_0) ./ (1.0 .+ exp.(theta_0))

# Solve it
res = Optim.optimize(Q, theta_0, Newton(), Optim.Options(x_tol = 1e-3, f_tol = 1e-3))

###################

# PART 4

# Estimating the consumption response to taxes: calculate a derivative
function dc_dtau(gamma,tau,h)
    # Calculate c with tau + h
    # <cs_p, ls_p = parallel_solve_all_Ec_El(... >
    # Calculate c with tau - h
    # <cs_p, ls_p = parallel_solve_all_Ec_El(... >
    # Take differences and average out
    # <> 
end

# Calculate the derivative
dc_dtau(gamma_hat, tau_hat, 0.01)