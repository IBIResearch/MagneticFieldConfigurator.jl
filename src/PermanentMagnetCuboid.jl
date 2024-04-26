export PermanentMagnetCuboid

struct PermanentMagnetCuboid <: MagneticDipoleField
  name::String
  c::CoordinateSystem
  magnetization::Float64
  length::Float64
  width::Float64
  height::Float64
end

function toDict(c::PermanentMagnetCuboid)
  params = invoke(toDict, Tuple{MagneticDipoleField}, c)
  params["type"] = "PermanentMagnetCuboid"
  params["width"] = c.width
  params["length"] = c.length
  params["height"] = c.height
  params["magnetization"] = c.magnetization
  return params
end

function PermanentMagnetCuboid(params::Dict)
  name = params["name"]
  c = CoordinateSystem(params["coordinates"])
  magnetization = params["magnetization"]
  width = params["width"]
  length = params["length"]
  height = params["height"]
  return PermanentMagnetCuboid(name,c,magnetization,length,width,height)
end

function getGrid(c::PermanentMagnetCuboid)
  Nw = 5
  Nl = 5
  Nh = 5
  positions = zeros(3,Nw,Nl,Nh)
  dV = (c.length / Nl)*(c.width / Nw)*(c.height / Nh)

  for h=1:Nh
    for l=1:Nl
      for w=1:Nw
        posx =  ((l-0.5)/Nl-0.5) *c.length
        posy =  ((w-0.5)/Nw-0.5) *c.width
        posz =  ((h-0.5)/Nh-0.5) *c.height

        positions[1,w,l,h] = posx
        positions[2,w,l,h] = posy
        positions[3,w,l,h] = posz
      end
    end
  end
  return reshape(positions,Val(2)),dV
end
