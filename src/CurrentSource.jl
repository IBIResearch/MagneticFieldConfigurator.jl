export CurrentSource, current!, absFieldAtUnitCurrentAndReferencePositions

mutable struct CurrentSource
  connectedCoils::Vector{Vector{AbstractCoil}}
  factors::Vector{Vector{Float64}}
  currents::Vector{Float64}
  maxCurrents::Vector{Float64}
  factorCurrentToVolt::Vector{Float64}
  referencePositions::Vector{SVector{3,Float64}}
end

function Base.:(==)(a::T, b::T) where {T<:CurrentSource}
  return a.connectedCoils == b.connectedCoils && a.factors == b.factors && a.currents == b.currents &&
         a.maxCurrents == b.maxCurrents && a.factorCurrentToVolt == b.factorCurrentToVolt &&
         a.referencePositions == b.referencePositions
end

Base.length(c::CurrentSource) = length(c.connectedCoils)

function CurrentSource(connectedCoils::Vector{<:Vector{<:AbstractField}}; 
                       factors = nothing, currents::Vector{Float64} = zeros(length(connectedCoils)),
                       maxCurrents::Vector{Float64} = fill(Inf,length(connectedCoils)),
                       factorCurrentToVolt::Vector{Float64} = ones(length(connectedCoils)),
                       referencePositions = defaultReferencePositions(connectedCoils))

  if factors == nothing
    factors = [ones(length(connectedCoils[i])) for i=1:length(connectedCoils)]
  end

  return CurrentSource(connectedCoils,factors,currents,maxCurrents,factorCurrentToVolt,referencePositions)
end

function CurrentSource(connectedCoils::Vector{<:AbstractField}; factors = nothing, kargs...)
  connectedCoils_ = [AbstractCoil[connectedCoils[i]] for i=1:length(connectedCoils)]
  if factors == nothing
    factors_ = [ones(length(connectedCoils_[i])) for i=1:length(connectedCoils)]
  else
    factors_ = [[factors[i]] for i=1:length(connectedCoils)]
  end
  return CurrentSource(connectedCoils_; factors=factors_, kargs...)
end

function CurrentSource(cc::ComposedField; kargs...)
  return CurrentSource(cc.fields; kargs...)
end

function CurrentSource(params::Dict, generators::ComposedField)
  connectedCoilsStr = params["connectedCoils"]
  connectedCoils = [[generators.fields[findfirst(g->g.name == name, generators.fields)] for name in connectedCoilsStr[i]] for i=1:length(connectedCoilsStr)]

  factors = params["factors"]
  currents = params["currents"]
  maxCurrents = get(params, "maxCurrents", fill(Inf,length(currents)))
  factorCurrentToVolt = get(params, "factorCurrentToVolt", ones(length(currents)))
  if haskey(params, "referencePositions")
    referencePositions = [SVector{3,Float64}(params["referencePositions"][3*(i-1)+j] for j=1:3) for i=1:length(connectedCoils)]
  else
    referencePositions = defaultReferencePositions(connectedCoils)
  end
  return CurrentSource(connectedCoils,factors,currents,maxCurrents,factorCurrentToVolt,referencePositions)
end

function toDict(c::CurrentSource)
  params = Dict{String,Any}()
  connectedCoilsStr = [[c.connectedCoils[i][l].name for l=1:length(c.connectedCoils[i])] for i=1:length(c.connectedCoils)]
  params["connectedCoils"] = connectedCoilsStr
  params["factors"] = c.factors
  params["currents"] = c.currents
  params["maxCurrents"] = c.maxCurrents
  params["factorCurrentToVolt"] = c.factorCurrentToVolt
  params["referencePositions"] = vec([c.referencePositions[i][j] for i=1:length(c.referencePositions) for j=1:3])
  return params
end

function current!(c::CurrentSource, currents::Vector{Float64})
  c.currents .= currents
  for i=1:length(c.connectedCoils)  
    for l=1:length(c.connectedCoils[i])
      c.connectedCoils[i][l].I = c.currents[i]*c.factors[i][l]
    end
  end
end


function defaultReferencePositions(connectedCoils)
  referencePositions = Vector{SVector{3,Float64}}(undef,length(connectedCoils))
  for i=1:length(connectedCoils)
    referencePositions[i] = mean([connectedCoils[i][l].c.center for l=1:length(connectedCoils[i])]) 
  end
  return referencePositions
end

function absFieldAtUnitCurrentAndReferencePositions(c::CurrentSource)
  absFields = zeros(length(c.connectedCoils))
  for i=1:length(c.connectedCoils)
    field = zeros(3)
    for l=1:length(c.connectedCoils[i])
      field .+= sensitivity(c.connectedCoils[i][l], c.referencePositions[i]) * c.factors[i][l]
    end
    absFields[i] += norm(field)
  end
  return absFields
end