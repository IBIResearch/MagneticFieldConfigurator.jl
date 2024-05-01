export MagneticFieldSystem, toFile, fromFile

@kwdef struct MagneticFieldSystem
  generators::ComposedField
  source::CurrentSource
end

function Base.:(==)(a::T, b::T) where {T<:MagneticFieldSystem}
  return a.generators == b.generators && a.source == b.source
end

function MagneticFieldSystem(params::Dict)
  generatorsDict = params["FieldGenerators"]
  generatorsDict["name"] = "FieldGenerators"
  generators = AbstractField(generatorsDict)
  source = CurrentSource(params["CurrentSource"], generators)
  return MagneticFieldSystem(generators, source)
end

function MagneticFieldSystem(filename::String)
  params = TOML.parsefile(filename)
  MagneticFieldSystem(params)
end

function toFile(filename::String, fs::MagneticFieldSystem)
  open(filename,"w") do fd
    params = Dict{String,Any}()
    params["FieldGenerators"] = toDict(fs.generators)
    params["CurrentSource"] = toDict(fs.source)
    TOML.print(fd, params)
  end
end



