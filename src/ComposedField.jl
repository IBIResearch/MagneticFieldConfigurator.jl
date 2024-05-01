export ComposedField

struct ComposedField <: AbstractField
  name::String
  c::CoordinateSystem
  fields::Vector{AbstractField}

  ComposedField(name::Union{String,Nothing}, args...) = new(newFieldName(ComposedField,name), args...)
end

function Base.:(==)(a::T, b::T) where {T<:ComposedField}
  if a.name != b.name || a.c != b.c || length(a.fields) != length(b.fields)
    return false
  end
  a_ = sort(a.fields, by=x->x.name)
  b_ = sort(b.fields, by=x->x.name)
  return a_ == b_
end

Base.length(c::ComposedField) = length(c.fields)

ComposedField(name::String, fields::AbstractVector) = ComposedField(name, CoordinateSystem(), fields)
ComposedField(fields::AbstractVector) = ComposedField(nothing, CoordinateSystem(), fields)
ComposedField(fields...) = ComposedField([fields...])

function ComposedField(params::Dict)
  name = params["name"]
  c = CoordinateSystem(params)
  fields = AbstractField[]
  for (key,value) in params
    if typeof(value) <: Dict
      value["name"] = key
      push!(fields, AbstractField(value))
    end
  end
  return ComposedField(name,c,fields)
end

function toDict(c::ComposedField)
  params = invoke(toDict, Tuple{AbstractField}, c)
  params["type"] = "ComposedField"
  for field in c.fields
    params[field.name] = toDict(field)
  end
  return params
end

Base.:(+)(a::AbstractField,b::AbstractField) = ComposedField([a,b])
Base.:(+)(a::ComposedField,b::AbstractField) = ComposedField([a.fields...,b])
Base.:(+)(a::AbstractField,b::ComposedField) = ComposedField([a,b.fields...])
Base.:(+)(a::ComposedField,b::ComposedField) = ComposedField([a.fields...,b.fields...])

function Base.getindex(c::ComposedField, pos::AbstractVector)
  B = zeros(Float64,3)
  for l=1:length(c.fields)
    B[:] .+= c.fields[l][pos]
  end
  return B
end
