using MagneticFieldConfigurator, GLMakie, MMR

cR1 = RectangularCoil("test", CoordinateSystem([1,0,0], [0,1,0], [+0.04/2*0,0,0]), 1.0, 98, 0.045, 0.032, 0.0, 0.003, 0.007, 0.015)
cR2 = RectangularCoil("test", CoordinateSystem([-1,0,0], [0,-1,0], [-0.04/2,0,0],), 1.0, 98, 0.045, 0.032, 0.0, 0.003, 0.007, 0.015)

generators = ComposedField("FieldGenerators",[cR1,cR2])
source = CurrentSource(generators; factors=Float64[1,1], currents=ones(length(generators)))
receiver = InductiveReceiver(generators; factors = Float64[1,1])
system = MagneticFieldSystem(generators, source, receiver, BoundingBox([0.1, 0.1, 0.1], [0.0, 0.0, 0.0]))

ind1 = inductance(cR1)
ind2 = inductance(cR2)
coupling = couplingFactor(cR2,cR1)
@info """
inductance cR1: $(ind1)
inductance cR2: $(ind2)
couplingFactor: $(coupling)
sum inductance: $(ind1+ind2+2*abs(coupling))
"""