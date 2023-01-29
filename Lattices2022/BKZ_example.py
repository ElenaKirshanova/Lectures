
# source https://www.maths.ox.ac.uk/system/files/attachments/lab-02.pdf

from fpylll import *
from fpylll.algorithms.bkz import BKZReduction
from math import log



from fpylll.algorithms.bkz2 import BKZReduction as BKZ2
import matplotlib.pyplot as plt




#A = IntegerMatrix.random(60, "qary", k=30, bits=30)

#bkz = BKZReduction(A) #инстанция класса BKZReduction
#print('before BKZ:', log(A[0].norm(),2))
#bkz(BKZ.EasyParam(15, max_loops=8)) #maxloops = число bkz-туров, запуск BKZ редукции
#print('after BKZ:', log(A[0].norm(),2))
#bkz(BKZ.EasyParam(15, max_loops=8), tracer=True)
#print(bkz.trace.get(("tour", 4)).report()) #for tracer=True

"""
k = 40
flags = BKZ.AUTO_ABORT
#print('flags:', flags, BKZ.AUTO_ABORT, BKZ.MAX_LOOPS,BKZ.VERBOSE)
par = BKZ.Param(k, strategies=BKZ.DEFAULT_STRATEGY, max_loops=8, flags=flags) # инстанция класса с пар-ми BKZ
bkz = BKZ2(A) #инстанция класса BKZ# или
#bkz = BKZ2(GSO.Mat(A)) # или
#bkz = BKZ2(LLL.Reduction(GSO.Mat(A)))
_ = bkz(par) # запуск BKZ редукции на A c пар-ми par
print(log(A[0].norm(),2))
"""

"""
A = IntegerMatrix.random(80, "qary", k=40, bits=30)
k = 55
tours = 3

LLL.reduction(A)
M = GSO.Mat(A)
M.update_gso()
d = A.nrows

colours = ["#4D4D4D", "#5DA5DA", "#FAA43A", "#60BD68", "#F17CB0", "#B2912F", "#B276B2", "#DECF3F", "#F15854"]
norms = [[log(M.get_r(i,i)) for i in range(d)]]
plt.plot(norms[0],label="lll", color=colours[0])

par = BKZ.Param(block_size=k,strategies=BKZ.DEFAULT_STRATEGY)
bkz = BKZ2(M)

for i in range(tours):
    bkz.tour(par)
    norms += [[log(M.get_r(j,j)) for j in range(d)]]
    plt.plot(norms[i+1],label="tour %d"%i, color=colours[i+1])

legend = plt.legend(loc='upper center')
plt.show()
"""
