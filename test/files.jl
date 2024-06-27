@testset "Files" begin
  r = 0.1
  I = 1.0
  c1 = CircularCoil(CoordinateSystem(SA[-0.1,0,0]), I, 1, r, 0, 0)
  c2 = CircularCoil(CoordinateSystem(SA[0.1,0,0]), -I, 1, r, 0, 0)
  c3 = RectangularCoil(CoordinateSystem(SA[-0.1,0,0]), I, 1, 3*r, 3*r, 0.0, 0, 0)
  c4 = RectangularCoil(CoordinateSystem(SA[0.1,0,0]), -I, 1, 3*r, 3*r, 0.0, 0, 0)
  generators = ComposedField("FieldGenerators",[c1,c2,c3,c4])
  source = CurrentSource(generators; factors=Float64[1,1,1,1], currents=I*ones(length(generators)))
  receiver = InductiveReceiver(generators; factors = Float64[1,1,1,1])
  system = MagneticFieldSystem(generators, source, receiver)

  @test BoundingBox(c1) == BoundingBox([0.0, 0.2, 0.2], [-0.1, 0.0, 0.0])
  @test BoundingBox(c3) == BoundingBox([0.0, 0.30000000000000004, 0.30000000000000004], [-0.1, 0.0, 0.0])  
  @test system.bbox == BoundingBox([0.2, 0.30000000000000004, 0.30000000000000004], [0.0, 0.0, 0.0])

  save("test.toml", system)
  systemFromFile = MagneticFieldSystem("test.toml")

  @test system == systemFromFile

  h5open("test.h5", "w") do file
    write(file, system)
  end

  systemFromHDFFile = h5open("test.h5", "r") do file
    MagneticFieldSystem(file)
  end
  
  @test system == systemFromHDFFile

  fig = Figure()
  ax = Axis3(fig[1,1], xlabel = "x / cm", ylabel = "y / cm", zlabel = "z / cm")

  x_ = range(-0.15,0.15,length=25)
  y_ = range(-0.15,0.15,length=20)
	
  current!(source, [I,-I,I,-I])

  field = [norm(generators[x,y,0.0]) for y in y_, x in x_]
  maxfield = maximum(field)*0.1

  pl2 = heatmap!(ax, x_, y_, field'; transformation=(:xy, 0.0),  
                    colorrange = (0,maxfield) )

  plot!(ax, generators)
  save("testComposed.png", fig)
end