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
  curvature::Float64
  color::RGBA{Float64}

  RectangularCoil(name, c, I, windings, sideA, sideB, cornerRadius, length, thickness, curvature=0.0, color=RGBA(0/255,73/255,146/255,1.0)) = 
     new(newFieldName(RectangularCoil,name), c, I, windings, sideA, sideB, cornerRadius, length, thickness, curvature, color)
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
  params["curvature"] = c.curvature
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
  curvature = get(params, "curvature", 0.0)
  col = get(params, "color", [1,0,0,1])
  color = RGBA{Float64}(col[1], col[2], col[3], col[4])

  return RectangularCoil(name,c,I,windings,sideA,sideB,cornerRadius,length,thickness,curvature,color)
end

function getWire(c::RectangularCoil)
  Ns = 30
  Nr = Ns * 4
  Nt = c.thickness > 0 ? 10 : 1
  Nl = c.length > 0 ? 10 : 1
  positions = zeros(3,Nr,Nt,Nl)
  paths = zeros(3,Nr,Nt,Nl)

  if c.curvature == 0.0

    for l=1:Nl
      for t=1:Nt
        posx = Nl > 1 ? -(l-0.5)/Nl*c.length : 0.0
        th = Nt > 1 ? (t-0.5)/Nt*c.thickness : 0.0

        sideA = c.sideA - 2*th
        sideB = c.sideB - 2*th
        r = 1

        for o in (1,-1)
          for s=1:Ns
            positions[1,r,t,l] = posx
            positions[2,r,t,l] = -o*sideB/2
            positions[3,r,t,l] = -o*sideA/2 + o*(s-0.5)/Ns*sideA
            paths[1,r,t,l] = 0
            paths[2,r,t,l] = 0
            paths[3,r,t,l] = -o*sideA/Ns/Nl/Nt
            r += 1
          end

          for s=1:Ns
            positions[1,r,t,l] = posx
            positions[2,r,t,l] = -o*sideB/2 + o*(s-0.5)/Ns*sideB
            positions[3,r,t,l] = o*sideA/2
            paths[1,r,t,l] = 0
            paths[2,r,t,l] = -o*sideB/Ns/Nl/Nt
            paths[3,r,t,l] = 0
            r += 1
          end
        end
      end
    end
  else

    for t=1:Nt
      th = Nt > 1 ? (t-0.5)/Nt*c.thickness : 0.0
      for l=1:Nl
        sideA = c.sideA - 2*th
        sideB = c.sideB - 2*th

        ang = sideB / 2.0 / (-c.curvature);

        if ang > pi
          ang = pi
        end
        h = c.curvature * (1- cos(ang)) 
        s_ = -c.curvature * sin(ang)
      
        posx = (Nl > 1 ? -(l-0.5)/Nl*c.length : 0.0) 

        r = 1
        for o in (1,-1)
          for s=1:Ns
            positions[1,r,t,l] = posx - h
            positions[2,r,t,l] = -o*s_ 
            positions[3,r,t,l] = -o*sideA/2 + o*(s-0.5)/Ns*sideA
            paths[1,r,t,l] = 0
            paths[2,r,t,l] = 0
            paths[3,r,t,l] = -o*sideA/Ns/Nl/Nt
            r += 1
          end

          for s=1:Ns
            α = -ang + 2*(s-0.5)/Ns*ang
            h_ = c.curvature * (1.0 - cos(α)) 
            positions[1,r,t,l] = posx-h_ 
            positions[2,r,t,l] = -o*c.curvature*sin(α)

            positions[3,r,t,l] = o*sideA/2
            paths[1,r,t,l] = -o*sin(α)*sideB/Ns/Nl/Nt
            paths[2,r,t,l] = -o*cos(α)*sideB/Ns/Nl/Nt
            paths[3,r,t,l] = 0
            r += 1
          end
        end

      end
    end
  end
  return reshape(positions,Val(2)), reshape(paths,Val(2))
end

BoundingBox(c::RectangularCoil) = BoundingBox(abs.(c.c.basis*[c.length,c.sideA,c.sideB]),c.c.center)