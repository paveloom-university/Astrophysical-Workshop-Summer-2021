# This script
# 1) takes the measurements of apparent magnitudes in the R and I filters
#    and the polarization estimates of the BL Lacertae blazar;
# 2) plots the light curves in both filters;
# 3) plots the color index;
# 4) plots the polarization variation.

using DelimitedFiles # Loading delimited files
using Plots # Plotting
using Statistics # Basic statistics

# Use the GR backend for plots
gr()

# Change the default parameters of plots
default(fontfamily = "Computer Modern", dpi=300)

# Load the data of the R filter
DF_R = readdlm("$(@__DIR__)/../materials/bllacr.dat", ' ')

# Load the data of the I filter
DF_I = readdlm("$(@__DIR__)/../materials/bllaci.dat", ' ')

# Load the Julian days from the data of the R filter
JD_R = DF_R[:,1]

# Load the Julian days from the data of the I filter
JD_I = DF_I[:,1]

# Load the measurements of the apparent magnitudes in the R filter of the object
R = DF_R[:,2]

# Load the measurements of the apparent magnitudes in the I filter of the object
I = DF_I[:,2]

# Load the measurements of the apparent magnitudes in the R filter of the standards
Rₛ = [DF_R[:,4], DF_R[:,6]]

# Load the measurements of the apparent magnitudes in the I filter of the standards
Iₛ = [DF_I[:,4], DF_I[:,6]]

# Load the errors of the apparent magnitudes in the R filter of the standards
σRₛ = [DF_R[:,5], DF_R[:,7]]

# Load the errors of the apparent magnitudes in the I filter of the standards
σIₛ = [DF_I[:,5], DF_I[:,7]]

# Define which of the standards has the lesser mean of the errors
si = findmin(mean.([σRₛ, σIₛ]))[2]

# Calculate the color index
RI = R - I

# Write the color index to a file
open("calculated.dat", "w") do io
    print(io, [ "$(round(RI[i]; digits=4))\n" for i in 1:length(RI) ]...)
end

# Load the polarization data of the object
DF_P_OBJ = readdlm("$(@__DIR__)/../materials/bllacPPPx", ' ')

# Load the polarization data of the object and the standards
DF_P_ALL = readdlm("$(@__DIR__)/../materials/bllacPxall", ' ')

# Load the Julian days from the polarization data
JD_P = DF_P_OBJ[:,1]

# Load the polarization values of the object
P = DF_P_OBJ[:,3]

# Load the polarization values of a standard
Pₛ = DF_P_ALL[1+si:3:end,:][:,3]

# Filter outliers in the polarization data
JD_I = [JD_I[2]; JD_I[4:14]; JD_I[19:end]]
I = [I[2]; I[4:14]; I[19:end]]
Iₛ = [[Iₛ[1][2]; Iₛ[1][4:14]; Iₛ[1][19:end]], [Iₛ[2][2]; Iₛ[2][4:14]; Iₛ[2][19:end]]]
JD_R = [JD_R[2]; JD_R[4:14]; JD_R[19:end]]
R = [R[2]; R[4:14]; R[19:end]]
Rₛ = [[Rₛ[1][2]; Rₛ[1][4:14]; Rₛ[1][19:end]], [Rₛ[2][2]; Rₛ[2][4:14]; Rₛ[2][19:end]]]
RI = [RI[2]; RI[4:14]; RI[19:end]]
JD_P = [JD_P[2]; JD_P[4:14]; JD_P[19:end]]
P = [P[2]; P[4:14]; P[19:end]]
Pₛ = [Pₛ[2]; Pₛ[4:14]; Pₛ[19:end]]

# Print the number of the standard that's going to be used
println("\nThe index of the standard to be used in the plots: $(si)\n")

# Plot the light curve of the R filter
pR = scatter(JD_R, R; label="Объект", xlabel="JD", ylabel="R", legend=:outerright, yflip=true);

# Add the standard light curve of the R filter to the plot
plot!(pR, JD_R, Rₛ[si]; label="Стандарт");

# Save the figure
savefig(pR, "R.pdf");

# Plot the light curve of the I filter
pI = scatter(JD_I, I; label="Объект", xlabel="JD", ylabel="I", legend=:outerright, yflip=true);

# Add the standard light curve of the I filter to the plot
plot!(pI, JD_I, Iₛ[si]; label="Стандарт");

# Save the figure
savefig(pI, "I.pdf");

# Plot the color index
pRI = scatter(JD_R, RI; xlabel="JD", ylabel="R-I", legend=nothing);

# Save the figure
savefig(pRI, "R-I.pdf");

# Plot the variation of the polarization
pP = scatter(JD_P, P; label="Объект", xlabel="JD", ylabel="P (%)", legend=:outerright);

# Add the standard's polarization variation to the plot
plot!(pP, JD_P, Pₛ; label="Стандарт");

# Save the figure
savefig(pP, "P.pdf");