export HomogenousField

struct HomogenousField <: AbstractField
  name::String
  c::CoordinateSystem
  A::AbstractVector{Float64}
end

HomogenousField(A::AbstractVector{Float64}) = HomogenousField(CoordinateSystem(), A)

function Base.getindex(field::HomogenousField, pos::AbstractVector)
  posLocal = fromGlobalToLocal(field.c, pos)
  return fromLocalToGlobalWithoutPosition(field.c, field.A)
end
