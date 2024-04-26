x = range(-1,stop=1,length=100)
I = 100
r = 0.5

biotSavart(x,I,r) = I*4*pi*1e-7/2*r^2/((r^2+x^2)^(3/2))

c = CircularCoil("test", CoordinateSystem(), I, 1, r, 0, 0)


for x_ in x
  B1 = c[[x_,0,0]][1]
  B2 = biotSavart(x_,I,r)
  @test abs( B1 - B2 ) / abs(B2) < 1e-14
end

fig = Figure()
ax = Axis3(fig[1,1])
plot!(ax, c)
save("test.png", fig)


#=
A = B = L = 0.01
# There are some issues directly at the surface of the magnet
x = range(0.005,stop=0.04,length=35)
Br = 1.0

permMagCuboid(x,Br,A,B,L) = Br/pi*(  atan(A*B/(2*x*sqrt(4*x^2+A^2+B^2)))
                                   - atan(A*B/(2(L+x)*sqrt(4(L+x)^2+A^2+B^2))) )

c = PermanentMagnetCuboid("test",CoordinateSystem(),Br,A,B,L)

for x_ in x
  B1 = c[[x_,0,0]][1]
  B2 = permMagCuboid(x_,Br,A,B,L)
  @test abs( B1 - B2 ) / abs(B2) < 1e-4
end
=#