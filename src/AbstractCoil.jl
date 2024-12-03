export AbstractCoil, couplingFactor, inductance, getGlobalWire

abstract type AbstractCoil <: AbstractField end

Base.getindex(c::AbstractCoil, pos::AbstractVector) = c.I * sensitivity(c, pos)

function toDict(c::AbstractCoil)
  params = invoke(toDict, Tuple{AbstractField}, c)
  params["current"] = c.I
  return params
end

function sensitivity(c::AbstractCoil, pos::AbstractVector)
  B = zeros(3)

  posLocal = fromGlobalToLocal(c.c, pos)
  positions, paths = getWire(c)

  _sensitvityInner(B, positions, posLocal, paths)

  return fromLocalToGlobalWithoutPosition(c.c, c.windings*1e-7 * B)
end

function _sensitvityInner(B, positions, posLocal, paths)
  for l=1:size(positions,2)
    posDiff = posLocal - positions[:,l]
    B .+= cross(paths[:,l], posDiff ./ (norm(posDiff)^3))
  end
end

function magneticVectorPotentialSensitivity(c::AbstractCoil, pos)
  positions, paths = getWire(c)
  return magneticVectorPotentialSensitivity(c, positions, paths, pos)
end

function magneticVectorPotentialSensitivity(c::AbstractCoil, positions, paths, pos)
  factor = 1e-7 #*windings;

  valueTmp = zeros(3)
  posLocal = fromGlobalToLocal(c.c, pos)

  _magneticVectorPotentialSensitivityInner(valueTmp, positions, paths, posLocal)

  return fromLocalToGlobalWithoutPosition(c.c, factor * valueTmp)
end

function _magneticVectorPotentialSensitivityInner(valueTmp, positions, paths, posLocal)
  posDiff = zeros(Float64, 3)
  for l=1:size(positions,2)
    for d=1:3
      posDiff[d] = positions[d,l] - posLocal[d]
    end
    absValue = norm(posDiff)
    if absValue > 12e-12
      for d=1:3
        valueTmp[d] += paths[d,l] / absValue
      end
    end
  end
end

function couplingFactor(c1::AbstractCoil, c2::AbstractCoil)

  positions1, paths1 = getWire(c1)
  positions2, paths2 = getWire(c2)

  couplingFactor = _couplingFactorInner(c1, c2, positions1, positions2, paths1, paths2) * 
                  c1.windings * c2.windings

  return couplingFactor
end

function _couplingFactorInner(c1, c2, positions1, positions2, paths1, paths2)
  couplingFactor = 0.0
  for l=1:size(positions1,2)
    pos = fromLocalToGlobal(c1.c,positions1[:,l])
    path = fromLocalToGlobalWithoutPosition(c1.c,paths1[:,l])

    vecPot = magneticVectorPotentialSensitivity(c2, positions2, paths2, pos)
    couplingFactor += dot(vecPot, path)
  end
  return couplingFactor
end

inductance(c::AbstractCoil) = couplingFactor(c,c)

function getGlobalWire(c::AbstractCoil)
  positions, paths = getWire(c)
  posLoc = [fromLocalToGlobal(c.c, positions[:,l])[d] for d=1:3, l=1:size(positions,2)]
  pathGlob = [fromLocalToGlobalWithoutPosition(c.c, paths[:,l])[d] for d=1:3, l=1:size(paths,2)]
  return posLoc, pathGlob
end
