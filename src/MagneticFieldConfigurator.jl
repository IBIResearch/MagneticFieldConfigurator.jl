module MagneticFieldConfigurator

using StaticArrays
using TOML
using LinearAlgebra, Statistics

export AbstractField, toDict, fromFile, gradient
import Base: getindex

abstract type AbstractField end

getindex(field::AbstractField,x,y,z) = field[[x,y,z]]

function toDict(field::AbstractField)
  params = Dict{String,Any}()
  params["name"] = field.name
  params["coordinates"] = toDict(field.c)
  return params
end

function toFile(filename::String, field::AbstractField)
  open(filename,"w") do fd
    TOML.print(fd, toDict(field))
  end
end

function fromFile(filename::String)
  params = TOML.parsefile("test.toml")
  return AbstractField(params)
end

function AbstractField(params::Dict)
  if params["type"] == "ComposedField"
    return ComposedField(params)
  elseif params["type"] == "CircularCoil"
    return CircularCoil(params)
  else
    error(" $(params["type"]) not yet implemented!")
  end
end

function gradient(field::AbstractField, pos)
  Gx = (field[pos-[eps(),0,0]]-field[pos+[eps(),0,0]])[1]/(2*eps())
  Gy = (field[pos-[0,eps(),0]]-field[pos+[0,eps(),0]])[2]/(2*eps())
  Gz = (field[pos-[0,0,eps()]]-field[pos+[0,0,eps()]])[3]/(2*eps())
  return [Gx,Gy,Gz]
end

# TODO: not yet generic
function gradient(field::AbstractArray, pos, fov)
  x = pos[1]
  y = pos[2]
  Gx = (field[1,x-1,y]-field[1,x+1,y])/(2 * fov[1] / size(field,2) )
  Gy = (field[2,x,y-1]-field[2,x,y+1])/(2 * fov[2] / size(field,3) )
  return [Gx,Gy]
end

include("CoordinateSystem.jl")
include("GradientField.jl")
include("HomogenousField.jl")
include("ComposedField.jl")
include("Coil.jl")
include("CircularCoil.jl")
include("RectangularCoil.jl")
include("MagneticDipole.jl")
include("PermanentMagnetCuboid.jl")
include("IronCuboid.jl")


end
