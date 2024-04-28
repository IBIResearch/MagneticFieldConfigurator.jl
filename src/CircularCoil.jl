export CircularCoil, sensitivity

struct CircularCoil <: Coil
  name::String
  c::CoordinateSystem
  I::Float64
  windings::Float64
  radius::Float64
  length::Float64
  thickness::Float64

  CircularCoil(name::Union{String,Nothing}, args...) = new(newFieldName(CircularCoil,name), args...)
end

#CircularCoil(name::String, c::CoordinateSystem, I, radius) = CircularCoil(name, c, I,radius,1.0,0.0,0.0)
CircularCoil(c::CoordinateSystem, args...) = CircularCoil(nothing, c, args...)


function toDict(c::CircularCoil)
  params = invoke(toDict, Tuple{Coil}, c)
  params["type"] = "CircularCoil"
  params["radius"] = c.radius
  params["length"] = c.length
  params["thickness"] = c.thickness
  params["windings"] = c.windings
  return params
end

function CircularCoil(params::Dict)
  name = params["name"]
  c = CoordinateSystem(params)
  I = params["current"]
  radius = params["radius"]
  length = params["length"]
  thickness = params["thickness"]
  windings = params["windings"]
  return CircularCoil(name,c,I,windings,radius,length,thickness)
end

function getWire(c::CircularCoil)
  Nr = 40
  Nt = c.thickness > 0 ? 10 : 1
  Nl = c.length > 0 ? 10 : 1
  positions = zeros(3,Nr,Nt,Nl)
  paths = zeros(3,Nr,Nt,Nl)

  for l=1:Nl
    for t=1:Nt
      for r=1:Nr
        angle = (r-1)/Nr*2*pi
        radius = Nt > 1 ? c.radius-(t-0.5)/Nt*c.thickness : c.radius
        posx = Nl > 1 ? -(l-0.5)/Nl*c.length : 0.0
        positions[1,r,t,l] = posx
        positions[2,r,t,l] = radius*cos(angle)
        positions[3,r,t,l] = radius*sin(angle)
        paths[1,r,t,l] = 0
        paths[2,r,t,l] = -radius*2*pi/Nr/Nl/Nt*sin(angle)
        paths[3,r,t,l] = radius*2*pi/Nr/Nl/Nt*cos(angle)
      end
    end
  end
  return reshape(positions,Val(2)), reshape(paths,Val(2))
end
