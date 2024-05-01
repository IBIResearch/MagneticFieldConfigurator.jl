export MagneticFieldSystem, save, fromFile

@kwdef struct MagneticFieldSystem
  generators::ComposedField
  source::CurrentSource = CurrentSource([[]],[[]],[])
  receiver::InductiveReceiver = InductiveReceiver([[]],[])
end

function MagneticFieldSystem(generators::ComposedField, source::CurrentSource)
  return MagneticFieldSystem(generators, source, InductiveReceiver([[]],[]))
end

function MagneticFieldSystem(generators::ComposedField)
  return MagneticFieldSystem(generators, CurrentSource([[]],[[]],[]), InductiveReceiver([[]],[]))
end

function Base.:(==)(a::T, b::T) where {T<:MagneticFieldSystem}
  return a.generators == b.generators && a.source == b.source && a.receiver == b.receiver
end

function MagneticFieldSystem(params::Dict)
  generatorsDict = params["FieldGenerators"]
  generatorsDict["name"] = "FieldGenerators"
  generators = AbstractField(generatorsDict)
  source = CurrentSource(params["CurrentSource"], generators)
  receiver = InductiveReceiver(params["InductiveReceiver"], generators)
  return MagneticFieldSystem(generators, source, receiver)
end

function MagneticFieldSystem(filename::String)
  params = TOML.parsefile(filename)
  MagneticFieldSystem(params)
end

function FileIO.save(filename::String, fs::MagneticFieldSystem)
  open(filename,"w") do fd
    params = Dict{String,Any}()
    params["FieldGenerators"] = toDict(fs.generators)
    params["CurrentSource"] = toDict(fs.source)
    params["InductiveReceiver"] = toDict(fs.receiver)
    TOML.print(fd, params)
  end
end



