# Loading and preparing the data
using DataFrames, CSV
df = CSV.read("shares_data.csv", DataFrame)

# ----

N = nrow(df)
df.logsk_logs0 = log.(df.s_k) - log.(df.s_0);
df.is_B = (df.product .== "b");
df

# ----


X = [ones(N) df.p_k df.is_B];
Z = [ones(N) df.is_B df.steel df.labor];


# Moment conditions function


function g_i(theta::AbstractVector{T}) where T
    # DEMAND SIDE
    theta_d = theta[1:3] # demand parameters
    # Epsilons for demand side
    e_d = df.logsk_logs0 - (X * theta_d) 
    # Moment conditions for demand side
    # REPLACE THIS LINE <m_di = ... >

    # SUPPLY SIDE
    # Costs
    alpha = -theta[2] # we need it to estimate marginal costs
    c_k = df.p_k - 1/alpha .* 1 ./(1 .- df.s_k)

    theta_s = theta[4:7] # supply parameters
    # Epsilons for supply side
    e_s = c_k - (Z * theta_s)
    # Moment conditions for supply side
    # # REPLACE THIS LINE <m_si = ...>
  
    # Return matrices side by side (N x M)
    return([m_di m_si])
end



# GMM estimation

using LinearAlgebra
M = 8
W = I(M) # Identity Matrix
function Q(theta)
    # Get moment vectors
    m_i = g_i(theta)
    # Take means of each column
    G = [sum(m_i[:, k]) for k in 1:M] ./ N
    # Calculate Q    
    # REPLACE THIS LINE <...> 
end


# GMM estimation: initial guess

using GLM
ols_reg = lm(@formula(logsk_logs0 ~ 1 + p_k + is_B), df)
theta_0 = [coef(ols_reg); minimum(df.p_k); ones(3)./10]


# Step 1
using Optim
res = Optim.optimize(Q, theta_0, Newton(), Optim.Options(f_abstol=1e-10, g_abstol=0.0, g_reltol=0.0))
theta_1 =  res.minimizer


# Calculate W_hat
# REPLACE THIS LINE <W = inv(... >


# Step 2
# Use step 1 estimates as initial guess
res = Optim.optimize(Q, theta_1, Newton(), Optim.Options(f_abstol=1e-10, g_abstol=0.0, g_reltol=0.0))
theta_GMM =  res.minimizer

# Define E[g_i]
function Eg(theta_GMM)
    gi = g_i(theta_GMM)
    Eg = [sum(gi[:, k]) for k in 1:M] ./ N; # This take means of each column
    return Eg
end

# Standard errors

using ForwardDiff
D_GMM = ForwardDiff.jacobian(Eg, theta_GMM);
S_GMM = g_i(theta_GMM)'  * g_i(theta_GMM) ./N;
V_GMM = inv(D_GMM' * inv(S_GMM) * D_GMM) ./N

SE_GMM = sqrt.(diag(V_GMM));
[theta_GMM SE_GMM (theta_GMM-1.96*SE_GMM) (theta_GMM+1.96*SE_GMM)]



# Marginal cost estimation
alpha_hat = -theta_GMM[2]
df.c_k = df.p_k - 1/alpha_hat .* 1 ./(1 .- df.s_k)


using Plots, LaTeXStrings
plot(histogram(df.c_k[.!df.is_B], label=L"Pred. $c_a$", bins=30), histogram(df.c_k[df.is_B], label=L"Pred. $c_b$", bins=30))



# Lerner index

df.lerner_k = (df.p_k - df.c_k) ./ df.p_k;

# Firm A
sum(df.lerner_k[.!df.is_B])./(N/2)

# Firm B
sum(df.lerner_k[df.is_B])./(N/2)

