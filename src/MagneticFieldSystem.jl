export MagneticFieldSystem, save, fromFile, txSensitivities, rxSensitivities

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

function Base.write(file::HDF5.File, fs::MagneticFieldSystem; path="/fieldSystem")
  buf = IOBuffer()
  params = Dict{String,Any}()
  params["FieldGenerators"] = toDict(fs.generators)
  params["CurrentSource"] = toDict(fs.source)
  params["InductiveReceiver"] = toDict(fs.receiver)
  TOML.print(buf, params)
  str = String(take!(buf))
  write(file, path, str)
  return
end

function MagneticFieldSystem(file::HDF5.File; path="/fieldSystem")
  str = read(file, path)
  params = TOML.parse(str)
  return MagneticFieldSystem(params)
end

function txSensitivities(fs::MagneticFieldSystem, pos::AbstractVector)
  txSens = zeros(Float64,3,length(fs.source))
  for i=1:length(fs.source)
    for l=1:length(fs.source.connectedCoils[i])
      txSens[:,i] .+= sensitivity(fs.source.connectedCoils[i][l], pos) *
                      fs.source.factors[i][l]
    end
  end
  return txSens
end

function rxSensitivities(fs::MagneticFieldSystem, pos::AbstractVector)
  rxSens = zeros(Float64,3,length(fs.receiver))
  for i=1:length(fs.receiver)
    for l=1:length(fs.receiver.connectedCoils[i])
      rxSens[:,i] .+= sensitivity(fs.receiver.connectedCoils[i][l], pos) *
                      fs.receiver.factors[i][l]
    end
  end
  return rxSens
end