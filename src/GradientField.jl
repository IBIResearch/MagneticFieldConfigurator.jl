export GradientField

struct GradientField <: AbstractField
  name::String
  c::CoordinateSystem
  G::Matrix{Float64}
end

GradientField(c::CoordinateSystem, G::Vector) = GradientField(c,diagm(G))
GradientField(G) = GradientField(CoordinateSystem(),G)

function getindex(field::GradientField, pos::Vector)
  posLocal = fromGlobalToLocal(field.c, pos)
  return fromLocalToGlobalWithoutPosition(c.c, field.G*posLocal)
end
