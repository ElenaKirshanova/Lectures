from fpylll import *
from math import pi, e, log
import matplotlib.pyplot as plt

from fpylll.algorithms.bkz2 import BKZReduction as BKZ2


import json

FPLLL.set_random_seed(1)
n, bits = 120, 40
A = IntegerMatrix.random(n, "qary", k=n/2, bits=bits)
beta = 60
tours = 6
par = BKZ.Param(block_size=beta,
                strategies=BKZ.DEFAULT_STRATEGY)

LLL.reduction(A)

M = GSO.Mat(A)
M.update_gso()

norms = [[log(M.get_r(i,i)) for i in range(n)]]


bkz = BKZ2(M)

for i in range(tours):
    bkz.tour(par)
    norms += [[log(M.get_r(i,i)) for i in range(n)]]

#CO = ["#4D4D4D", "#5DA5DA", "#FAA43A", "#60BD68",
#           "#F17CB0", "#B2912F", "#B276B2", "#DECF3F", "#F15854"]
Colors = ["#12035D","#22107F","#45349E","#6F5FBF",
        "#9587DE","#B1A5EE","#DED8FA"]

X = range(n)
plt.plot(X,norms[1], color=Colors[0],label="LLL")

for i,_norms in enumerate(norms[1:]):
    plt.plot(X, _norms,color=Colors[i+1],label="tour %d"%i)
    plt.legend(loc="lower left")

plt.show()
plt.close()
