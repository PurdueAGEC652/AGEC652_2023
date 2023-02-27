## Slide codes


### In-class activity: autodiff

# 1. Make sure you have the `ForwardDiff` package
using ForwardDiff

# 2. Define your function `my_fun`
my_fun(x) = log(x[1] + 10.0)

# 3. Define `x` as a 1-element array containing `5.5`
x = [5.5]

# 4. Define the gradient operator `g` using `ForwardDiff.gradient(f,x)`
g(f,x) = ForwardDiff.gradient(f,x)

# 5. Use `g` to evaluate the derivative
g(my_fun,x)[1]

# 6. Derive the analytic solution and compare to your numeric one
1/(10.0 + x[1])

##########


# Package for drawing random numbers
using Distributions

# Define a function to do the integration for an arbitrary function
function integrate_mc(f, lower, upper, num_draws)
  # Draw from a uniform distribution
  xs = rand(Uniform(lower, upper), num_draws)
  # Expectation = mean(x)*volume
  expectation = mean(f(xs))*(upper - lower)
end

f(x) = x.^2;
integrate_mc(f, 0, 10, 1000)


# Generic function to integrate with midpoint
function integrate_midpoint(f, a, b, N)
    # Calculate h given the interval [a,b] and N nodes
    h = (b-a)/(N-1)
    
    # Calculate the nodes starting from a+h/2 til b-h/2
    x = collect(a+h/2:h:b-h/2)
    
    # Calculate the expectation    
    expectation = sum(h*f(x))
end;

using QuantEcon;
# Our generic function to integrate with Gaussian quadrature
function integrate_gauss(f, a, b, N)
    # This function get nodes and weights for Gauss-Legendre quadrature
    x, w = qnwlege(N, a, b)

    # Calculate expectation
    expectation = sum(w .* f(x))
end;



### In-class activity: integration with QuantEcon
using QuantEcon;

f(x) = 1.0./(x.^2 .+ 1.0)

# 1. Use `quadrect` to integrate using Monte Carlo
# MC with 1000 nodes
quadrect(f, 1000, 0.0, 1.0, "R")

# 2. Use `qnwtrap` to integrate using the Trapezoid rule quadrature
# Trapezoid: x and w with 7 nodes
x, w = qnwtrap(7, 0.0, 1.0)
# Perform quadrature approximation
sum(w .* f(x))

# 3. Use `qnwlege` to integrate using Gaussian quadrature
# Gaussian: x and w with 7 nodes
x, w = qnwlege(7, 0.0, 1.0)
# Perform quadrature approximation
sum(w .* f(x))


# True value: integral of 1/(x^2 + 1) from 0 to 1 is arctan(1) = pi/4