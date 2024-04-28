@testset "Files" begin
  r = 0.1
  I = 1.0
  c1 = CircularCoil(CoordinateSystem(SA[-0.1,0,0]), I, 1, r, 0, 0)
  c2 = CircularCoil(CoordinateSystem(SA[-0.1,0,0]), I, 1, r, 0, 0)
  cc = ComposedField(c1,c2)

  toFile("test.toml", cc)

  ccFromFile = fromFile("test.toml")

  @test cc == ccFromFile
end