module MagneticFieldConfiguratorMakieExt

using MagneticFieldConfigurator, Makie, LinearAlgebra

function ibicolors(i::Integer)
  ibicolors_ = [RGBf.(0/255,73/255,146/255), # blue
	  RGBf.(239/255,123/255,5/255),	# orange (dark)
	  RGBf.(138/255,189/255,36/255),	# green
	  RGBf.(178/255,34/255,41/255), # red
	  RGBf.(170/255,156/255,143/255), # mocca
	  RGBf.(87/255,87/255,86/255),	# black (text)
	  RGBf.(255/255,223/255,0/255), # yellow
	  RGBf.(104/255,195/255,205/255),# "TUHH"
	  RGBf.(45/255,198/255,214/255), #  TUHH
	  RGBf.(193/255,216/255,237/255)]

  return ibicolors_[mod1(i,length(ibicolors_))]
end

function Makie.plot!(ax, cc::ComposedField, shift=[0,0,0], scale=1)

  for l=1:length(cc.fields)
    if typeof(cc.fields[l]) <: AbstractCoil
      plot!(ax, cc.fields[l], shift, scale)
    end
  end
  return
end

function Makie.plot!(ax, coil::AbstractCoil, shift=[0,0,0], scale=1)
  pos, path = getGlobalWire(coil)

  x = pos[1,:].*scale .+shift[1]
  y = pos[2,:].*scale .+shift[2]
  z = pos[3,:].*scale .+shift[3]
  lines!(ax, x, y, z, color = coil.color, linewidth = 5)
  # linestyle = :dotted
  return
end

function Makie.plot!(ax, system::MagneticFieldSystem)
  plot!(ax, system.generators)
  return
end

function Makie.plot!(ax, c::CoordinateSystem; scale=1)

  centerP = Point3f(c.center...)

  factor = 0.01*scale

  pl = arrows!(ax, [centerP,centerP,centerP], [ Point3f(c.basis[:,1]...)*factor, 
     Point3f(c.basis[:,2]...)*factor, Point3f(c.basis[:,3]...)*2*factor], 
    linewidth=factor/8, color=[ibicolors(2),ibicolors(1),:black], arrowsize=factor/4)

  return pl
end

include("MagneticFieldViewer.jl")
  
end