module MagneticFieldConfigurator

using Reexport
@reexport using StaticArrays
using TOML
using LinearAlgebra, Statistics
using FileIO
using HDF5

export μ₀

const μ₀ = 4π*1e-7

function __init__()
  #detect_toml(io) = endswith(io.name,".toml>")
  #add_format(format"TOML", detect_toml,[".toml"], [:TOML])
end

include("CoordinateSystem.jl")
include("BoundingBox.jl")
include("AbstractField.jl")
include("GradientField.jl")
include("HomogenousField.jl")
include("ComposedField.jl")
include("AbstractCoil.jl")
include("CircularCoil.jl")
include("RectangularCoil.jl")
include("MagneticDipole.jl")
include("PermanentMagnetCuboid.jl")
include("IronCuboid.jl")
include("CurrentSource.jl")
include("InductiveReceiver.jl")
include("MagneticFieldSystem.jl")

export viewer
function viewer end

end
