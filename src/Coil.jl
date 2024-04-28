export Coil, couplingFactor, inductance, getGlobalWire

abstract type Coil <: AbstractField end

Base.getindex(c::Coil, pos::AbstractVector) = c.I * sensitivity(c, pos)

function toDict(c::Coil)
  params = invoke(toDict, Tuple{AbstractField}, c)
  params["current"] = c.I
  return params
end

function sensitivity(c::Coil, pos::AbstractVector)
  B = zeros(3)

  posLocal = fromGlobalToLocal(c.c, pos)
  positions, paths = getWire(c)

  for l=1:size(positions,2)
    posDiff = posLocal - positions[:,l]
    B[:] .+= cross(paths[:,l], posDiff ./ (norm(posDiff)^3))
  end

  return fromLocalToGlobalWithoutPosition(c.c, c.windings*1e-7 * B)
end

function magneticVectorPotentialSensitivity(c::Coil, pos)
  factor = 1e-7 #*windings;

  valueTmp = zeros(3)
  posLocal = fromGlobalToLocal(c.c, pos)
  positions, paths = getWire(c)

  for l=1:size(positions,2)
    posDiff =  positions[:,l] - posLocal
    absValue = norm(posDiff)
    if absValue > 12e-12
      valueTmp[:] .+= paths[:,l] / absValue
    end
  end
  return fromLocalToGlobalWithoutPosition(c.c, factor * valueTmp)
end

function couplingFactor(c1::Coil, c2::Coil)
  couplingFactor = 0.0

  positions, paths = getWire(c1)

  for l=1:size(positions,2)
    pos = fromLocalToGlobal(c1.c,positions[:,l])
    path = fromLocalToGlobalWithoutPosition(c1.c,paths[:,l])

    vecPot = magneticVectorPotentialSensitivity(c2, pos)
    couplingFactor += dot(vecPot, path)
  end

  couplingFactor = couplingFactor * c1.windings * c2.windings

  return couplingFactor
end

inductance(c::Coil) = couplingFactor(c,c)

function getGlobalWire(c::Coil)
  positions, paths = getWire(c)
  posLoc = [fromLocalToGlobal(c.c, positions[:,l])[d] for d=1:3, l=1:size(positions,2)]
  pathGlob = [fromLocalToGlobalWithoutPosition(c.c, paths[:,l])[d] for d=1:3, l=1:size(paths,2)]
  return posLoc, pathGlob
end
