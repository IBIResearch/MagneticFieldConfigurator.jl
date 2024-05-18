export InductiveReceiver

mutable struct InductiveReceiver
  connectedCoils::Vector{Vector{AbstractCoil}}
  factors::Vector{Vector{Float64}}
end

function Base.:(==)(a::T, b::T) where {T<:InductiveReceiver}
  return a.connectedCoils == b.connectedCoils && a.factors == b.factors 
end

Base.length(c::InductiveReceiver) = length(c.connectedCoils)

function InductiveReceiver(connectedCoils::Vector{<:Vector{<:AbstractField}}; 
                       factors = nothing)
  if factors == nothing
    factors = [ones(length(connectedCoils[i])) for i=1:length(connectedCoils)]
  end

  return InductiveReceiver(connectedCoils,factors)
end

function InductiveReceiver(connectedCoils::Vector{<:AbstractField}; factors = nothing)
  connectedCoils_ = [AbstractCoil[connectedCoils[i]] for i=1:length(connectedCoils)]
  if factors == nothing
    factors_ = [ones(length(connectedCoils_[i])) for i=1:length(connectedCoils)]
  else
    factors_ = [[factors[i]] for i=1:length(connectedCoils)]
  end
  return InductiveReceiver(connectedCoils_; factors=factors_)
end

function InductiveReceiver(cc::ComposedField; kargs...)
  return InductiveReceiver(cc.fields; kargs...)
end

function InductiveReceiver(params::Dict, generators::ComposedField)
  connectedCoilsStr = params["connectedCoils"]
  connectedCoils = [[generators.fields[findfirst(g->g.name == name, generators.fields)] for name in connectedCoilsStr[i]] for i=1:length(connectedCoilsStr)]

  factors = params["factors"]
  return InductiveReceiver(connectedCoils,factors)
end

function toDict(c::InductiveReceiver)
  params = Dict{String,Any}()
  connectedCoilsStr = [[c.connectedCoils[i][l].name for l=1:length(c.connectedCoils[i])] for i=1:length(c.connectedCoils)]
  params["connectedCoils"] = connectedCoilsStr
  params["factors"] = c.factors
  return params
end
