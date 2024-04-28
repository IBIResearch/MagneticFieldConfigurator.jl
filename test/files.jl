@testset "Files" begin
  r = 0.1
  I = 1.0
  c1 = CircularCoil(CoordinateSystem(SA[-0.1,0,0]), I, 1, r, 0, 0)
  c2 = CircularCoil(CoordinateSystem(SA[0.1,0,0]), -I, 1, r, 0, 0)
  c3 = RectangularCoil(CoordinateSystem(SA[-0.1,0,0]), I, 1, 3*r, 3*r, 0.0, 0, 0)
  c4 = RectangularCoil(CoordinateSystem(SA[0.1,0,0]), -I, 1, 3*r, 3*r, 0.0, 0, 0)
  cc = ComposedField(c1,c2,c3,c4)

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

  plot!(ax, cc)
  save("testComposed.png", fig)
end