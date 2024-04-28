abstract type MagneticDipoleField <: AbstractField end

function Base.getindex(c::MagneticDipoleField, pos::AbstractVector)
  B = zeros(3)

  posLocal = fromGlobalToLocal(c.c, pos)
  positions, dV = getGrid(c)

  magnetization = c.magnetization * dV / (4*pi*1e-7)

  for l=1:size(positions,2)
    r = posLocal - positions[:,l]
    len = norm(r)
    M = SVector(magnetization,0,0)
    B[:] .+= 3*r*(dot(r,M))/(len^5) - M/(len^3)
  end

  return fromLocalToGlobalWithoutPosition(c.c, 1e-7 * B)
 end

function toDict(c::MagneticDipoleField)
  params = invoke(toDict, Tuple{AbstractField}, c)
  return params
end
