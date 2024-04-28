@testset "Files" begin
  r = 0.1
  I = 1.0
  c1 = CircularCoil(CoordinateSystem(SA[-0.1,0,0]), I, 1, r, 0, 0)
  c2 = CircularCoil(CoordinateSystem(SA[0.1,0,0]), -I, 1, r, 0, 0)
  cc = ComposedField(c1,c2)

  toFile("test.toml", cc)
  ccFromFile = fromFile("test.toml")

  @test cc == ccFromFile

  fig = Figure()
  ax = Axis3(fig[1,1], xlabel = "x / cm", ylabel = "y / cm", zlabel = "z / cm")


  x_ = range(-0.15,0.15,length=25)
  y_ = range(-0.15,0.15,length=20)
	
  field = [norm(cc[x,y,0.0]) for y in y_, x in x_]
  maxfield = maximum(field)*0.1

  pl2 = heatmap!(ax, x_, y_, field'; transformation=(:xy, 0.0),  
                    colorrange = (0,maxfield) )
  #Colorbar(ax, pl2, label="H / mT")

  plot!(ax, cc)
  save("testComposed.png", fig)
end