module MagneticFieldConfiguratorMakieExt

using MagneticFieldConfigurator, Makie

function Makie.plot!(ax, coilarray, shift=[0,0,0], scale=1)

  for l=1:length(coilarray)
    plot!(ax, coilarray[l], shift, scale)
  end
  return
end

function Makie.plot!(ax, coil::Coil, shift=[0,0,0], scale=1)
  pos, path = getGlobalWire(coil)

  x = pos[1,:].*scale .+shift[1]
  y = pos[2,:].*scale .+shift[2]
  z = pos[3,:].*scale .+shift[3]
  lines!(ax, x, y, z, color = Makie.wong_colors()[1], linewidth = 5)
  # linestyle = :dotted
  return
end
  

end