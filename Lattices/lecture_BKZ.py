from fpylll import *
from math import pi, e, log
import matplotlib.pyplot as plt

from fpylll.algorithms.bkz2 import BKZReduction as BKZ2


import json

FPLLL.set_random_seed(1)
n, bits = 100, 40
A = IntegerMatrix.random(n, "qary", k=n/2, bits=bits)
beta = 40
tours = 6
par = BKZ.Param(block_size=beta,
                strategies=BKZ.DEFAULT_STRATEGY)

delta_0 = (beta/(2*pi*e) * (pi*beta)**(1/int(beta)))**(1/(2*beta-1))
alpha = delta_0**(-2*n/(n-1))

LLL.reduction(A)

M = GSO.Mat(A)
M.update_gso()


norms  = [[log(alpha**i * delta_0**n \
                     * 2**(bits/2))**2 for i in range(n)]]
#norms  = [map(log, [(alpha**i * delta_0**n \
#                     * 2**(bits/2))**2 for i in range(n)])]
#print(norms)

norms += [[log(M.get_r(i,i)) for i in range(n)]]


bkz = BKZ2(M)

for i in range(tours):
    bkz.tour(par)
    norms += [[log(M.get_r(i,i)) for i in range(n)]]

CO = ["#4D4D4D", "#5DA5DA", "#FAA43A", "#60BD68",
           "#F17CB0", "#B2912F", "#B276B2", "#DECF3F", "#F15854"]

X = range(n)
#Y = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
#plt.plot(X,norms[0])
plt.plot(X,norms[1], label="LLL")
#plt.plot(X, Y)
#plt.ylabel('blah')


#g  = line(zip(range(n), norms[0]), legend_label="GSA", color=CO[0])
#g += line(zip(range(n), norms[1]), legend_label="lll", color=CO[1])

for i,_norms in enumerate(norms[2:]):
    plt.plot(X, _norms,color=CO[i+2],label="tour %d"%i)
    plt.legend(loc="lower left")
    #plt.legend("tour %d"%i)

plt.show()
#plt.savefig("lab-plot-line-matplotlib.png", bbox_inches='tight')
plt.close()
