module MagneticFieldConfiguratorMakieExt

using MagneticFieldConfigurator, Makie, LinearAlgebra

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
  lines!(ax, x, y, z, color = Makie.wong_colors()[1], linewidth = 5)
  # linestyle = :dotted
  return
end
  

function MagneticFieldConfigurator.viewer(system::MagneticFieldSystem)
  fig = Figure()
  ax = Axis3(fig[1,1], xlabel = "x / cm", ylabel = "y / cm", zlabel = "z / cm")

  x_ = range(-0.15,0.15,length=25)
  y_ = range(-0.15,0.15,length=20)

  current!(system.source, system.source.currents)

  field = zeros(3, length(y_), length(x_))
  absfield = zeros(length(y_), length(x_))
  for i=1:length(y_)
    for j=1:length(x_)
      field[:,i,j] .= system.generators[x_[j],y_[i],0.0]
      absfield[i,j] = norm(field[:,i,j])
    end
  end
  maxfield = maximum(absfield)*0.1

  pl2 = heatmap!(ax, x_, y_, absfield'; transformation=(:xy, 0.0),  
                    colorrange = (0,maxfield) )

  arrows!(ax, x_[1:2:end], y_[1:2:end], field[1,1:2:end,1:2:end]'./maximum(absfield), 
          field[2,1:2:end,1:2:end]'./maximum(absfield), 
          arrowsize = 10.5, lengthscale = 0.3, color=:white, linewidth=5)

  plot!(ax, system.generators)
  return fig, ax
end

end