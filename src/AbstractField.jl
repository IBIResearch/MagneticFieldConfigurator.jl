export AbstractField, toDict, gradient

abstract type AbstractField end

function Base.:(==)(a::T, b::T) where {T<:AbstractField}
  N = fieldcount(typeof(a))
  for i in 1:N
      getfield(a, i) == getfield(b, i) || return false
  end
  return true  
end

const _fieldNames = Dict{Type, Vector{String}}()

function newFieldName(t::Type, name::String)
  if !haskey(_fieldNames, t)
    _fieldNames[t] = String[]
  end
  push!(_fieldNames[t], name)
  return name
end

function newFieldName(t::Type, ::Nothing)
  if !haskey(_fieldNames, t)
    _fieldNames[t] = String[]
  end
  counter = length(_fieldNames[t]) + 1
  name = ""
  while true
    name = "$(string(t))$(counter)"
    if !(name in _fieldNames[t])
      break
    end
    counter += 1
  end
  push!(_fieldNames[t], name)
  return name
end

Base.getindex(field::AbstractField,x,y,z) = field[SA[x,y,z]]

function toDict(field::AbstractField)
  params = Dict{String,Any}()
  params["center"] = field.c.center
  params["basis"] = vec(field.c.basis)
  return params
end

function fileio_save(f::File{format"TOML"}, field::AbstractField)
  open(filename,"w") do fd
    TOML.print(fd, toDict(field))
  end
end

function AbstractField(params::Dict)
  if params["type"] == "ComposedField"
    return ComposedField(params)
  elseif params["type"] == "CircularCoil"
    return CircularCoil(params)
  elseif params["type"] == "RectangularCoil"
    return RectangularCoil(params)
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