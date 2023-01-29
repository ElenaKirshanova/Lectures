from fpylll import *
from g6k import *
from g6k.utils.stats import SieveTreeTracer
from g6k.algorithms.bkz import pump_n_jump_bkz_tour
from fpylll.util import gaussian_heuristic


FPLLL.set_random_seed(1337)

#-------------------------------------------------------
# SVP
#-------------------------------------------------------
n = 60
A = IntegerMatrix.random(n, "qary", k=30, bits=30)
g6k = Siever(A, seed=0x1337) # g6k has its own seed

g6k.initialize_local(0, 0, n) # sieve the entire basis
g6k(alg="bgj1")
v = g6k.best_lifts()[0][2]
w = A.multiply_left(v)
print('norms:', sum(w_**2 for w_ in w), A[0].norm()**2)


#-------------------------------------------------------
# Simulate BKZ
#-------------------------------------------------------
A = IntegerMatrix.random(n, "qary", k=30, bits=30)
gh = gaussian_heuristic([g6k.M.get_r(i, i) for i in range(n)])
goal_r0 = (1.05**2) * gh

g6k = Siever(A, seed=0x1337) # g6k has its own seed
g6k.initialize_local(0, 0, n)
sp = g6k.params.new()
sp.threads = 1
g6k(alg="bgj1")

tracer = SieveTreeTracer(g6k, root_label=("nvsieve"), start_clocks=True)
for b in (20, 30, 40, 50, 60): # progressive BKZ
    pump_n_jump_bkz_tour(g6k, tracer,
                         b, pump_params={"down_sieve": True})
    print(A[0].norm()**2)
