export HomogenousField

struct HomogenousField <: AbstractField
  name::String
  c::CoordinateSystem
  A::Vector{Float64}
end

HomogenousField(A::Vector{Float64}) = HomogenousField(CoordinateSystem(), A)

function getindex(field::HomogenousField, pos::Vector)
  posLocal = fromGlobalToLocal(field.c, pos)
  return fromLocalToGlobalWithoutPosition(field.c, field.A)
end
