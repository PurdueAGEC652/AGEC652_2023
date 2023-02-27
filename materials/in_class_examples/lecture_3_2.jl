## Bisection - Slide 18

function bisection(f, lo, up)
    tolerance = 1e-3          # tolerance for solution
    mid = (lo + up)/2         # initial guess, bisect the interval
    difference = (up - lo)/2  # initialize bound difference

    while difference > tolerance         # loop until convergence
        println("Intermediate guess: $mid")
        if sign(f(lo)) == sign(f(mid)) # if the guess has the same sign as the lower bound
            lo = mid                   # a solution is in the upper half of the interval
        else                           # else the solution is in the lower half of the interval
            up = mid
        end
        mid = (lo + up)/2
        difference = (up - lo)/2       # update the difference 
    end
    println("The root of f(x) is $mid")
end


f(x) = -x^(-2) + x - 1
bisection(f, 0.2, 4.0)

#######################

# Function iteration - Slide 25
function function_iteration(f, initial_guess)
    tolerance = 1e-3   # tolerance for solution
    difference = Inf   # initialize difference
    x = initial_guess  # initialize current value
    
    while abs(difference) > tolerance # loop until convergence
        println("Intermediate guess: $x")
        x_prev = x  # store previous value
        x = x_prev - f(x_prev) # calculate next guess
        difference = x - x_prev # update difference
    end
    println("The root of f(x) is $x")
end;

f(x) = -x^(-2) + x - 1;
function_iteration(f, 1.0)

####################

# Newtown's method - Slide 35

function newtons_method(f, f_prime, initial_guess)
    tolerance = 1e-3   # tolerance for solution
    difference = Inf   # initialize difference
    x = initial_guess  # initialize current value
    
    while abs(difference) > tolerance # loop until convergence
        println("Intermediate guess: $x")
        x_prev = x  # store previous value
        x = x_prev - f(x_prev)/f_prime(x_prev) # calculate next guess
        # ^ this is the only line that changes from function iteration
        difference = x - x_prev # update difference
    end
    println("The root of f(x) is $x")
  end;


f(x) = -x^(-2) + x - 1;
f_prime(x) = 2x^(-3) + 1;
newtons_method(f, f_prime, 1.0)