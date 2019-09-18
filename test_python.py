import selalib_interpol as my
import numpy as np

NPTS1 = 129
NPTS2 = 129

eta1 = np.linspace(0.,1.0, NPTS1)
eta2 = np.linspace(0.,1.0, NPTS2)
X,Y = np.meshgrid(eta1, eta2)
X = X.transpose()
Y = Y.transpose()

pi = np.pi; sin = np.sin; cos = np.cos; exp = np.exp
data_in = cos(2.0*pi*X)*sin(2.0*pi*Y)

data_out = np.zeros_like(data_in)

# Computing slopes:
eta1_min = -2.0*pi * sin(2.0*pi*eta1[0])  * sin(2.0*pi*eta2)
eta1_max = -2.0*pi * sin(2.0*pi*eta1[-1]) * sin(2.0*pi*eta2)
eta2_min =  2.0*pi * cos(2.0*pi*eta1)     * cos(2.0*pi*eta2[0])
eta2_max =  2.0*pi * cos(2.0*pi*eta1)     * cos(2.0*pi*eta2[-1])
eta1_slopes = [eta1_min, eta1_max]
eta2_slopes = [eta2_min, eta2_max]


for j in range(NPTS2):
  for i in range (NPTS1):
     X[i,j] = i/float(NPTS1)
     Y[i,j] = j/float(NPTS2)

data_out = my.mp_int.interpolate_2d(data_in, X, Y, eta1_slopes, eta2_slopes)


print("=== Error = ", np.amax(abs(data_out-cos(2.0*pi*X)*sin(2.0*pi*Y))))

# X,Y = np.meshgrid(eta1, eta2)
# import pylab as pl
# pl.contourf(X,Y, data_in)
# pl.colorbar()
# pl.show(block=True)
# pl.clf()
# pl.contourf(X,Y, data_out)
# pl.colorbar()
# pl.show(block=True)

# Poisson test
NPTS1 = 512
NPTS2 = 512

eta1 = np.linspace(0., 1.0, NPTS1)
eta2 = np.linspace(0., 1.0, NPTS2)
X,Y = np.meshgrid(eta1, eta2)
X = X.transpose()
Y = Y.transpose()

pi = np.pi; sin = np.sin; cos = np.cos; exp = np.exp
k = 4*pi
# working test:
# data_in = -4.0*pi*pi*sin(2.0*pi*X)
# data_ex = sin(2.0*pi*X)
# not working tests:
# data_in = -2.0*k**3*sin(k*X)*cos(k*Y)
# data_ex = k*sin(k*X)*cos(k*Y)
# ......... 2
# data_in = -4.0*pi*pi*cos(2.0*pi*X)
# data_ex = cos(2.0*pi*X)
# ......... 3
data_in = (10000.0*X**2 - 10000.0*X + 10000.0*Y**2 -10000.0*Y + 4800.0)*exp(-((X-0.5)**2 +(Y-0.5)**2) / (2.0*(0.1)**2) )
data_ex = exp(-((X-0.5)**2 +(Y-0.5)**2) / (2.0*(0.1)**2) )

data_out = np.zeros_like(data_in)

data_out = my.mp_int.poisson_solver_periodic(NPTS1, NPTS2, data_in)
import matplotlib.pyplot as pl

pl.contourf(X,Y, data_in)
pl.title("Rho (cad datain)")
pl.axis('equal')

print(" DATA_OUT VALUES ")
print("MAX VAL = ", np.max(data_out))
print("MIN VAL = ", np.min(data_out))
X,Y = np.meshgrid(eta1, eta2)
import matplotlib.pyplot as pl
pl.subplot(1,3,1)
pl.contourf(X,Y, data_in)
pl.title("Rho (cad datain)")
pl.axis('equal')
pl.colorbar()
pl.subplot(1,3,2)
pl.contourf(X,Y, data_ex)
pl.title("Solution exacte")
pl.axis('equal')
pl.colorbar()
pl.subplot(1,3,3)
pl.contourf(X,Y, -data_out)
pl.title("Solution approchee")
pl.axis('equal')
pl.colorbar()
pl.show(block=True)


print("ERROR = ", np.amax(np.abs(data_out+data_ex)))
