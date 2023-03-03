# AGEC 652 - Lecture 3.2 - An example of symbolic derivations with Symbolics.jl

# using Pkg
# Pkg.add("Symbolics")
# Pkg.add("Latexify")

# Import packages
using Symbolics, Latexify

# Declare symbolic variables and constants
@variables q_1, q_2, ϵ, c_1, c_2

# Define the symbols for individual profits
symb_π_1 = ((q_1 + q_2))^(-1/ϵ) * q_1 - 1/2 * c_1 * (q_1^2)
symb_π_2 = ((q_1 + q_2))^(-1/ϵ) * q_2 - 1/2 * c_2 * (q_2^2)

# Calculate the symbolic derivatives
symb_f_1 = Symbolics.derivative(symb_π_1, q_1)
symb_f_2 = Symbolics.derivative(symb_π_2, q_2)

# We can use Latexify to render these expressions in Latexify
latexify([symb_f_1, symb_f_2])

# Find the symbolic Jacobian matrix
symb_jacobian = Symbolics.jacobian([symb_f_1, symb_f_2], [q_1, q_2])
latexify(simplify(symb_jacobian))


# Now we are ready to convert the symbolic representation to numerics. First
# we assign the global values for our constant parameters
ϵ = 1.6
c_1 = 0.6
c_2 = 0.8

# Then, create actual Julia functions for us to use with the Newton's method
# (build_function returns the code of a Julia function. Then, eval
# reads that code and executes it, creating a function for us)
jl_f_1 = eval(build_function(symb_f_1, q_1, q_2)) # Julia function for f_1
jl_f_2 = eval(build_function(symb_f_2, q_1, q_2)) # and for f_2

# You can test some values
jl_f_1(0.2, 0.2)
jl_f_2(0.2, 0.2)

# Stack f_1 and f_2 to get the multidimensional f. Note that
# this new function is wrapper that maps a vector of q into
# the symbolic variables q_1 and q_2
f(q) = [jl_f_1(q[1], q[2]),
        jl_f_2(q[1], q[2])]

# Test it
f([0.2, 0.2])

# Now, we are ready to create a Julia function for the Jacobian
# (build_function function actually give us two options in this case. The First
# is a function that allocates a new matrix whereas the second is a memory-optimized
# version that modifies a pre-allocated matrix in place. We will use the first one here)
# matrix to save on memory)
jl_jacobian = eval(build_function(symb_jacobian, q_1, q_2)[1]) 

# Again, we use a wrapped function to map vector q into symbolic variables
f_jacob(q) = jl_jacobian(q[1], q[2])

# Test it
f_jacob([0.2, 0.2])

# We can compare with the code from the slides, which define the analytic functions "by hand" 
function slides_f(q)
    Q = sum(q)
    F = Q^(-1/ϵ) .- (1/ϵ)Q^(-1/ϵ-1) .*q .- [c_1, c_2] .*q
end
slides_f([0.2, 0.2])

using LinearAlgebra
function slides_f_jacobian(q)
    Q = sum(q)
    A = (1/ϵ)*Q^(-1/ϵ-1)
    B = (1/ϵ+1)*Q^(-1)
    J = -A .* [2 1; 1 2] + (A*B) .* [q q] - LinearAlgebra.Diagonal([c_1, c_2])
end;
slides_f_jacobian([0.2, 0.2])

# Finally, we can compare with numerical derivates using the ForwardDiff package
using ForwardDiff
# Define the jacobian operator
jac_oper(f, q) = ForwardDiff.jacobian(f, q)

# Define the profit function to compare our f_1 and f_2 functions
π(q) = sum(q)^(-1/ϵ) .* q - 1/2 * ([c_1, c_2] .* q.^2)
π([0.2, 0.2]) # The diagonal elements match!

# Now the jacobian matrix of f
jac_oper(slides_f, [0.2, 0.2]) # All good!







