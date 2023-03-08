# AGEC 652 - Spring 2023
# Your name

# Model paremeters
α = [5.0; 3.0];
β = [2.0; 6.0];
η = [1.2; 1.5];
ρ = [1.6; 1.2];

# Excess demand function (of a price vector and parameter vectors)
E(p) = α .* p.^(-η) - β .* p.^(ρ);
E([0.5; 0.5])  

###### Step 1: solve the no-trade model using NLsolve.nlsolve and calculate $p$ and $E$ for each country



###### Step 2: solve the no-trade-friction model using NLsolve.nlsolve and calculate $p$ and $E$ for each country



###### Step 3: solve the unconstrained flow model using NLsolve.nlsolve and calculate $p$ and $E$ for each country



###### Step 4: solve the constrained flow model using NLsolve.mcpsolve and calculate $p$ and $E$ for each country.
#### But first, program E^(-1)

