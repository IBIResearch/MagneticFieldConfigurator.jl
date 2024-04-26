export IronCuboid, updateMField

mutable struct IronCuboid <: MagneticDipoleField
  name::String
  c::CoordinateSystem
  magnetization::Float64
  length::Float64
  width::Float64
  height::Float64
  positions::Matrix{Float64}
  dV::Float64
  mfield::Matrix{Float64}
end

function IronCuboid(name,c,magnetization,length,width,height)
  c = IronCuboid(name,c,magnetization,length,width,height,zeros(1,1),0.0,zeros(1,1))
  initGrid(c)
  return c
end

function toDict(c::IronCuboid)
  params = invoke(toDict, Tuple{MagneticDipoleField}, c)
  params["type"] = "IronCuboid"
  params["width"] = c.width
  params["length"] = c.length
  params["height"] = c.height
  params["magnetization"] = c.magnetization
  return params
end

function IronCuboid(params::Dict)
  name = params["name"]
  c = CoordinateSystem(params["coordinates"])
  magnetization = params["magnetization"]
  width = params["width"]
  length = params["length"]
  height = params["height"]
  return IronCuboid(name,c,magnetization,length,width,height)
end

function updateMField(c::IronCuboid, field::AbstractField)
  c.mfield = zeros(3, size(c.positions,2))
  for i=1:size(c.positions,2)
    # FIXME: Make coordinate transform
    H = field[c.positions[:,i]]
    c.mfield[:,i] = 2*H / (4*pi*1e-7)
  end
end

getGrid(c::IronCuboid) = (c.positions, c.dV)

function initGrid(c::IronCuboid)
  Nw = 11
  Nl = 11
  Nh = 11
  positions = zeros(3,Nw,Nl,Nh)
  dV = (c.length / Nl)*(c.width / Nw)*(c.height / Nh)

  for h=1:Nh
    for l=1:Nl
      for w=1:Nw
        posx =  -(l-0.5)/Nl*c.length
        posy =  ((w-0.5)/Nw-0.5) *c.width
        posz =  ((h-0.5)/Nh-0.5) *c.height

        positions[1,w,l,h] = posx
        positions[2,w,l,h] = posy
        positions[3,w,l,h] = posz
      end
    end
  end
  c.positions = reshape(positions,Val(2))
  c.dV = dV
end


function getindex(c::IronCuboid, pos::Vector)
  B = zeros(3)

  posLocal = fromGlobalToLocal(c.c, pos)
  positions, dV = getGrid(c)

  for l=1:size(positions,2)
    r = posLocal - positions[:,l]
    len = norm(r)
    M = c.mfield[:,l].* dV
    B[:] .+= 3*r*(dot(r,M))/(len^5) - M/(len^3)
  end

  return fromLocalToGlobalWithoutPosition(c.c, 1e-7 * B)
 end
