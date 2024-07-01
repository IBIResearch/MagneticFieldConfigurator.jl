export RectangularCoil, sensitivity

mutable struct RectangularCoil <: AbstractCoil
  name::String
  c::CoordinateSystem
  I::Float64
  windings::Float64
  sideA::Float64
  sideB::Float64
  cornerRadius::Float64
  length::Float64
  thickness::Float64
  color::RGBA{Float64}

  RectangularCoil(name, c, I, windings, sideA, sideB, cornerRadius, length, thickness, color=RGBA(0/255,73/255,146/255,1.0)) = 
     new(newFieldName(RectangularCoil,name), c, I, windings, sideA, sideB, cornerRadius, length, thickness, color)
end

RectangularCoil(c::CoordinateSystem, args...) = RectangularCoil(nothing, c, args...)

function toDict(c::RectangularCoil)
  params = invoke(toDict, Tuple{AbstractCoil}, c)
  params["type"] = "RectangularCoil"
  params["sideA"] = c.sideA
  params["sideB"] = c.sideB
  params["cornerRadius"] = c.cornerRadius
  params["length"] = c.length
  params["thickness"] = c.thickness
  params["windings"] = c.windings
  params["color"] = [c.color.r, c.color.g, c.color.b, c.color.alpha]
  return params
end

function RectangularCoil(params::Dict)
  name = params["name"]
  c = CoordinateSystem(params)
  I = params["current"]
  sideA = params["sideA"]
  sideB = params["sideB"]
  cornerRadius = params["cornerRadius"]
  length = params["length"]
  thickness = params["thickness"]
  windings = params["windings"]
  col = get(params, "color", [1,0,0,1])
  color = RGBA{Float64}(col[1], col[2], col[3], col[4])

  return RectangularCoil(name,c,I,windings,sideA,sideB,cornerRadius,length,thickness,color)
end

function getWire(c::RectangularCoil)
  Ns = 30
  Nr = Ns * 4
  Nt = c.thickness > 0 ? 10 : 1
  Nl = c.length > 0 ? 10 : 1
  positions = zeros(3,Nr,Nt,Nl)
  paths = zeros(3,Nr,Nt,Nl)

  for l=1:Nl
    for t=1:Nt
      posx = Nl > 1 ? -(l-0.5)/Nl*c.length : 0.0
      th = Nt > 1 ? (t-0.5)/Nt*c.thickness : 0.0

      sideA = c.sideA - 2*th
      sideB = c.sideB - 2*th

      r = 1
      for s=1:Ns
        positions[1,r,t,l] = posx
        positions[2,r,t,l] = -sideA/2
        positions[3,r,t,l] = -sideB/2 + (s-0.5)/Ns*sideB
        paths[1,r,t,l] = 0
        paths[2,r,t,l] = 0
        paths[3,r,t,l] = -sideB/Ns/Nl/Nt
        r += 1
      end

      for s=1:Ns
        positions[1,r,t,l] = posx
        positions[2,r,t,l] = -sideA/2 + (s-0.5)/Ns*sideA
        positions[3,r,t,l] = sideB/2
        paths[1,r,t,l] = 0
        paths[2,r,t,l] = -sideA/Ns/Nl/Nt
        paths[3,r,t,l] = 0
        r += 1
      end

      for s=1:Ns
        positions[1,r,t,l] = posx
        positions[2,r,t,l] = sideA/2
        positions[3,r,t,l] = sideB/2 - (s-0.5)/Ns*sideB
        paths[1,r,t,l] = 0
        paths[2,r,t,l] = 0
        paths[3,r,t,l] = sideB/Ns/Nl/Nt
        r += 1
      end

      for s=1:Ns
        positions[1,r,t,l] = posx
        positions[2,r,t,l] = sideA/2 - (s-0.5)/Ns*sideA
        positions[3,r,t,l] = -sideB/2 
        paths[1,r,t,l] = 0
        paths[2,r,t,l] = sideA/Ns/Nl/Nt
        paths[3,r,t,l] = 0
        r += 1
      end
    end
  end
  return reshape(positions,Val(2)), reshape(paths,Val(2))
end

BoundingBox(c::RectangularCoil) = BoundingBox(abs.(c.c.basis*[c.length,c.sideA,c.sideB]),c.c.center)