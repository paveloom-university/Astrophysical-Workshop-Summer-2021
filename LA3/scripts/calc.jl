# This script
# 1) takes the measurements of apparent magnitudes in the B and V filters
#    of stars from the The Pleiades open star cluster;
# 2) plots the Hertzsprung–Russell diagram of the cluster;
# 3) calculates the distance to the cluster.

using Measurements # Numbers with uncertainty
using Plots # Plotting
using Polynomials # Fitting polynomials
using Statistics # Basic statistics

# Use the GR backend for plots
gr()

# Change the default parameters of plots
default(fontfamily = "Computer Modern", dpi=300)

# Load the measurements of the apparent magnitudes in the B filter
B = [
    13.311,
    4.201,
    8.948,
    10.246,
    13.060,
    15.343,
    8.472,
    13.009,
    11.162,
    6.820,
    9.932,
    13.750,
    2.780,
    8.951,
    16.988,
    9.956,
    8.154,
    5.379,
    10.586,
    7.060,
    12.128,
    16.851,
    9.340,
    7.550,
]

# Load the measurements of the apparent magnitudes in the V filter
V = [
    12.530,
    4.310,
    8.602,
    9.700,
    12.049,
    14.337,
    8.110,
    12.022,
    10.520,
    6.798,
    9.458,
    12.631,
    2.870,
    7.718,
    16.402,
    8.801,
    6.459,
    5.451,
    10.022,
    6.946,
    11.344,
    15.703,
    9.171,
    7.420,
]

# Load standard values of the color index
BVₛ = [-0.35, -0.31, -0.16, 0, 0.13, 0.27, 0.42, 0.58, 0.70, 0.89, 1.18, 1.45, 1.63, 1.80]

# Load standard absolute magnitudes
Mₛ = [-5.8, -4.1, -1.1, -0.7, 2.0, 2.6, 3.4, 4.4, 5.1, 5.9, 7.3, 9.0, 11.8, 16.0]

# Calculate the differences
BV = B .- V

# Write the differences to a file
open("calculated.dat", "w") do io
    print(io, [ "$(round(BV[i]; digits=3))\n" for i in 1:length(BV) ]...)
end

# Get a subset of stars from the Main Sequence
BVₘ = [BV[1:13]; BV[18:end]]
Vₘ = [V[1:13]; V[18:end]]

# Plot the Hertzsprung–Russell diagram (Main Sequence only)
p1 = scatter(
    BVₘ,
    Vₘ;
    label="Главная последовательность",
    xlabel="B-V",
    ylabel="V",
    yflip=true,
);

# Add giants to the diagram
scatter!(p1, [BV[14]; BV[16:17]], [V[14]; V[16:17]], label="Звезды — красные гиганты");

# Add outliers to the diagram
scatter!(p1, [BV[15],], [V[15],], label="Выбросы");

# Add annotations
annotate!(p1, [ (BV[i] + 0.04, V[i] - 0.3, text("$(i)", 8, "Computer Modern")) for i in 1:24 ]);

# Save the figure
savefig(p1, "diagram1.pdf");

# Plot the Hertzsprung–Russell diagram again (Main Sequence only)
p2 = scatter(
    BVₘ,
    Vₘ;
    label="Видимые зв. величины",
    xlabel="B-V",
    ylabel="V, M, V-M",
    yflip=true,
);

# Add standard absolute magnitudes to the plot
scatter!(p2, BVₛ, Mₛ, label="Абсолютные зв. величины");

# Fit a polynomial of degree 3 to the measured data
f = fit(BVₘ, Vₘ, 3)

# Plot the fitted polynomial
plot!(p2, f, extrema(BVₘ)..., label="Вид. зв. величины (полином 3-й степени)");

# Fit a polynomial of degree 3 to the standard data
fₛ = fit(BVₛ, Mₛ, 3)

# Plot the fitted polynomial
plot!(p2, fₛ, extrema(BVₛ)..., label="Абс. зв. величины (полином 3-й степени)");

# Calculate the difference of the polynomials on the subset of the measured data
Δf = f - fₛ
Δx = range(extrema(BVₘ)...; length=1000)
Δy = Δf.(Δx)

# Plot the difference of the polynomials
plot!(p2, Δx, Δy, label="Разница между полиномами")

# Save the figure
savefig(p2, "diagram2.pdf");

# Calculate the median and IQR of the difference
Q = quantile(Δy, (.25, .75))
ΔV = median(Δy) ± (Q[2] - Q[1])

# Print the median and IQR of the difference
println(
    "\nThe difference between the absolute and apparent magnitudes:\n\n",
    "$(ΔV) ᵐ",
)

# Calculate the distance to the cluster
D = @. exp10((ΔV + 5) / 5)

# Print the distance to the cluster
println(
    "\nThe distance to the cluster:\n\n",
    "$(D) pc\n",
)