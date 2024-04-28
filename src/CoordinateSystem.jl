export CoordinateSystem

struct CoordinateSystem
  basis::SMatrix{3,3,Float64}
  center::SVector{3,Float64}
end

function Base.:(==)(a::T, b::T) where {T<:CoordinateSystem}
  return a.basis == b.basis && a.center == b.center  
end

function CoordinateSystem(x,y,center)
  x_ = normalize(x)
  y_ = normalize(y)
  z = cross(x_,y_)
  return CoordinateSystem(hcat(x_,y_,z),center)
end

function CoordinateSystem(params::Dict)
  center = params["center"]
  xyz = params["basis"]
  c = CoordinateSystem(xyz[1:3],xyz[4:6],center)
end

function toDict(c::CoordinateSystem)
  params = Dict{String,Any}()
  params["basis"] = vec(c.basis)
  params["center"] = c.center
  return params
end

CoordinateSystem(x::AbstractVector,y::AbstractVector) = CoordinateSystem(x,y,zeros(3))
CoordinateSystem() = CoordinateSystem([1.0,0.0,0.0],[0.0,1.0,0.0])
CoordinateSystem(center::AbstractVector) = CoordinateSystem(SA[1,0,0],SA[0,1,0],center)

fromLocalToGlobalWithoutPosition(c::CoordinateSystem, pos) =
                                 c.basis*pos

fromGlobalToLocalWithoutPosition(c::CoordinateSystem, pos) =
                                 transpose(c.basis)*pos

fromGlobalToLocal(c::CoordinateSystem, pos) =
      fromGlobalToLocalWithoutPosition(c, pos - c.center)

fromLocalToGlobal(c::CoordinateSystem, pos) =
      fromLocalToGlobalWithoutPosition(c, pos) + c.center
