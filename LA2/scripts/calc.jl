# This script
# 1) takes the measurements of the apparent magnitudes of different
#    galaxies and the wavelengths of the K Ca II and H Ca II lines
#    found in their spectra as input;
# 2) calculates the distances to the galaxies and their velocities;
# 3) fits a linear regression model to these data;
# 4) plots the Hubble diagram and saves it in the current directory.

using Measurements # Numbers with uncertainty
using Plots # Plotting
using Statistics # Basic statistics

# Use the GR backend for plots
gr()

# Change the default font for plots
default(fontfamily = "Computer Modern")

# Return the nominal value of a measurement
value = Measurements.value

# Return the uncertainty of a measurement
uncertainty = Measurements.uncertainty

# Load the wavelengths

# Each line represents an object: the first element in each array
# is the measurement of the wavelength of the K Ca II line,
# and the second one — of the H Ca II line. If the last one is missing,
# it means the line wasn't present in the observed spectra
wls = [
    # Ursa Major II (uma2-1)
    [4484.0 ± 1.0],
    # Ursa Major I (uma1-3)
    [4130.0 ± 1.0, 4167.0 ± 1.0],
    # Coma Berenices (Coma1)
    [4012.0 ± 1.0, 4048.0 ± 1.0],
    # Bootes (Boot1)
    [4445.0 ± 1.0, 4485.0 ± 1.0],
    # Corona Borealis (CrBor1)
    [4209.0 ± 1.0, 4246.0 ± 1.0],
    # Sagittarius (GAS)
    [3973.0 ± 1.0, 4008.0 ± 1.0]
]

# Set the standard wavelengths of the H and K Ca II lines
const λₖ = 3933.67
const λₕ = 3968.847

# Set the value of the speed of light (km/s)
const c = 2.99792458e5

# Initialize the velocities vector
vels = Vector{Measurement{Float64}}()

# For each object in the data
for obj in wls
    # Initialize the velocities in this scope
    vₖ = 0.0
    vₕ = 0.0
    # For each line in the object's data
    for (i, λ) in enumerate(obj)
        # If that's a K Ca II line
        if i == 1
            # Calculate the velocity for this line
            vₖ = c * (λ - λₖ) / λₖ
        # If that's an H Ca II line
        elseif i == 2
            # Calculate the velocity for this line
            vₕ = c * (λ - λₕ) / λₕ
        end
    end
    # If there is only one observed line (presumably, K Ca II)
    if size(obj, 1) == 1
        # Save the velocity of this line
        push!(vels, vₖ)
    # Otherwise,
    else
        # Save the mean of the two velocities
        push!(vels, mean((vₖ, vₕ)))
    end
end

# Load the magnitudes
mags = [
    # Ursa Major II (uma2-1)
    16.87,
    # Ursa Major I (uma1-3)
    14.49,
    # Coma Berenices (Coma1)
    12.30,
    # Bootes (Boot1)
    16.52,
    # Corona Borealis (CrBor1)
    15.08,
    # Sagittarius (GAS)
    10.98
]

# Set the absolute magnitude (with an
# assumption it's the same for all objects)
M = -22

# Calculate the distances (Mpc)
dists = exp10.((mags .- M .+ 5) ./ 5) ./ 1e6

# Write the distances and velocities to a file
open("calculated.dat", "w") do io
    println(io, dists, '\n', value.(vels), '\n', uncertainty.(vels))
end

# In terms of velocities to distances, calculate the slope coefficient
k = dists \ vels

# Calculate the velocities using that coefficient
pred = dists * value(k)

# Print the coefficient
println("\nThe slope coefficient is $(k).\n")

# Get the permutation vector that puts the distances in sorted order
mask = sortperm(dists)

# Plot the data and the fitted line
p = plot(
    dists[mask],
    value.(vels[mask]);
    label="Измеренные",
    xlabel="Расстояние (Мпк)",
    ylabel="Скорость (км/c)",
    markershape=:circle,
    dpi=300,
    legend=:bottomright
);
plot!(p, dists[mask], pred[mask]; label="Вписанные", markershape=:circle);

# Save the figure
savefig(p, "result.pdf");