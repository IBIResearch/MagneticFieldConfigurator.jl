### A Pluto.jl notebook ###
# v0.19.42

using Markdown
using InteractiveUtils

# ╔═╡ 6977e0b4-0133-11ef-0e3c-69ae73970e30
begin
    import Pkg
    # activate a temporary environment
    Pkg.activate(mktempdir())
    Pkg.add(["CairoMakie", "PlutoUI", "LinearAlgebra", "Revise", "WGLMakie"
    ])
	Pkg.develop(path="/Users/knopp/.julia/dev/MagneticFieldConfigurator")
    using Revise
	using CairoMakie, PlutoUI, LinearAlgebra, MagneticFieldConfigurator
	import WGLMakie
	CairoMakie.activate!()
end

# ╔═╡ 5665878d-db78-4a94-9706-f2a2bbb189dc
let
  WGLMakie.activate!()
  fig = Figure(size=(700,400))

  ax1 = Axis3(fig[1,1], azimuth=pi/6, xlabel="x / cm", elevation=0.19,
	         ylabel="y / cm", zlabel="z / cm", 
             aspect=:data, protrusions=30,
  	         xlabeloffset=30, ylabeloffset=30, zlabeloffset=30, 
  	         viewmode=:fitzoom)
  #ax1 = LScene(fig[1,1], xlabel="x / cm")
	
  len = 0.01
  side = 0.11
  dirX = [0,0,1]
  dirY = [0,1,0]
	
  c1 = RectangularCoil("test", CoordinateSystem(dirX,dirY,[0,0,0]), 
			          1, 40, side, side, 0, len, len)
  c2 = RectangularCoil("test", CoordinateSystem(dirX,dirY,[0,0,side+len]), 
			          1, -40, side, side, 0, len, len)

  cc = c1+c2
	
  plot!(ax1, cc, [0,0,0], 100)

  z_ = range(-0.05,0.18,length=20)
  x_ = range(-0.08,0.08,length=20)
	
  field = [norm(cc[x,0.0,z]) for z in z_, x in x_]

  @info (maximum(field)-minimum(field)) / (minimum(field))
	
  ax2 = Axis(fig[1,2])
  #pl = lines!(ax2, z_.*100, -field)
  pl = heatmap!(ax2, x_.*100, z_.*100, field )
  Colorbar(fig[1, 3], pl)
  #ylims!(ax2, (0,9))
  fig
end

# ╔═╡ 10a00b64-10cb-4128-9634-b860f4c2ac90
let
  WGLMakie.activate!()
  fig = Figure(size=(700,500))

  ax1 = Axis3(fig[1,1:4], azimuth=pi/6, xlabel="x / cm", elevation=0.2,
	         ylabel="y / cm", zlabel="z / cm", 
             aspect=:data, protrusions=30,
  	         xlabeloffset=30, ylabeloffset=30, zlabeloffset=30, 
  	         viewmode=:fitzoom)
  #ax1 = LScene(fig[1,1:4])
	
  len = 0.025
  thick = 0.025
  dist = 0.25
  radius = dist + thick
  dirX = [0,0,1]
  dirY = [0,1,0]
	
  c1 = CircularCoil("test", CoordinateSystem(dirX,dirY,[0,0,-dist/2]), 
			          15, 100, radius, len, thick)
  c2 = CircularCoil("test", CoordinateSystem(-dirX,dirY,[0,0,dist/2]), 
			          -15, 100, radius, len, thick)

  cc = c1+c2
	
  plot!(ax1, cc, [0,0,0], 100)


  z_ = range(-dist*2,dist*2,length=35)
  x_ = range(-dist*2,dist*2,length=30)
	
  field = [norm(cc[x,0.0,z]) for z in z_, x in x_]
  maxfield = 30.0
	
  ax2 = Axis(fig[2,1], xlabel = "x / cm", ylabel = "z / cm")
  pl = heatmap!(ax2, x_.*100, z_.*100, field' * 1000, colorrange = (0,maxfield) )
  Colorbar(fig[2, 2], pl, label="H / mT")

  pl2 = heatmap!(ax1, x_.*100, z_.*100, field' * 1000; transformation=(:xz, 0.0),  
                    colorrange = (0,maxfield) )
	
  z_ = range(-0.045,0.045,length=25)
  x_ = range(-0.045,0.045,length=20)
	
  #field = [norm(cc[x,0.0,z]) for z in z_, x in x_]
  field = [cc[x,0.0,z][3] for z in z_, x in x_]

  @info (maximum(field)-minimum(field)) / (minimum(field))

  #@info " Inductance = $(inductance(c1)*1e6) μH"
	
  ax3 = Axis(fig[2,3], xlabel = "x / cm", ylabel = "z / cm")
  pl = heatmap!(ax3, x_.*100, z_.*100, field' * 1000 )
  Colorbar(fig[2, 4], pl, label="H / mT")
	
  fig
end

# ╔═╡ 83b6d2fe-2a41-4067-b737-5cc3ceb48719


# ╔═╡ bb921d3e-29b1-47b8-b47b-fd0f737e9e15
let
  WGLMakie.activate!()
  fig = Figure(size=(700,500))

  ax1 = Axis3(fig[1,1:4], azimuth=pi/6, xlabel="x / cm", elevation=0.2,
	         ylabel="y / cm", zlabel="z / cm", 
             aspect=:data, protrusions=30,
  	         xlabeloffset=30, ylabeloffset=30, zlabeloffset=30, 
  	         viewmode=:fitzoom) 
  #ax1 = LScene(fig[1,1:4])
	
  len = 0.025
  thick = 0.025
  dist = 0.25
  #side = dist + 2*thick
  side = 0.5 + 2*thick
  dirX = [0,0,1]
  dirY = [0,1,0]
	
  c1 = RectangularCoil("test", CoordinateSystem(dirX,dirY,[0,0,-dist/2]), 
			          15, 100, side, side, 0, len, thick)
  c2 = RectangularCoil("test", CoordinateSystem(-dirX,dirY,[0,0,dist/2]), 
			          -15, 100, side, side, 0, len, thick)

  cc = c1+c2
	
  plot!(ax1, cc, [0,0,0], 100)

  #z_ = range(0.005,dist-0.005,length=25)
  #x_ = range(-dist/2,+dist/2,length=20)
  z_ = range(-dist,dist,length=25)
  x_ = range(-dist,+dist,length=20)
	
  field = [norm(cc[x,0.0,z]) for z in z_, x in x_]
	
  maxfield = 10.0
  pl2 = heatmap!(ax1, x_.*100, z_.*100, field' * 1000; transformation=(:xz, 0.0),
                 colorrange = (0,maxfield))
	
  ax2 = Axis(fig[2,1], xlabel = "x / cm", ylabel = "z / cm")
  pl = heatmap!(ax2, x_.*100, z_.*100, field' * 1000, colorrange = (0,maxfield) )
  Colorbar(fig[2, 2], pl, label="H / mT")

  z_ = range(-0.05,0.05,length=25)
  x_ = range(-0.05,0.05,length=20)
	
  #field = [norm(cc[x,0.0,z]) for z in z_, x in x_]
  field = [cc[x,0.0,z][3] for z in z_, x in x_]


  @info (maximum(field)-minimum(field)) / (minimum(field))
  #@info " Inductance = $(inductance(c1)*1e6) μH"
	
  ax3 = Axis(fig[2,3], xlabel = "x / cm", ylabel = "z / cm")
  pl = heatmap!(ax3, x_.*100, z_.*100, field' * 1000 )
  Colorbar(fig[2, 4], pl, label="H / mT")
	
  fig
end

# ╔═╡ 02dc3df0-e270-431e-85d0-bf5807189b4a
let
  CairoMakie.activate!()
  fig = Figure(size=(700,500))

  ax1 = Axis3(fig[1,1:4], azimuth=pi/6, xlabel="x / cm", elevation=0.2,
	         ylabel="y / cm", zlabel="z / cm", 
             aspect=:data, protrusions=30,
  	         xlabeloffset=30, ylabeloffset=30, zlabeloffset=30, 
  	         viewmode=:fitzoom) 
	fig

end

# ╔═╡ Cell order:
# ╠═6977e0b4-0133-11ef-0e3c-69ae73970e30
# ╠═5665878d-db78-4a94-9706-f2a2bbb189dc
# ╠═10a00b64-10cb-4128-9634-b860f4c2ac90
# ╠═83b6d2fe-2a41-4067-b737-5cc3ceb48719
# ╠═bb921d3e-29b1-47b8-b47b-fd0f737e9e15
# ╠═02dc3df0-e270-431e-85d0-bf5807189b4a
