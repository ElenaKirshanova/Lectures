from fpylll import *

N = 14854697210674840878452702602518793472677337256956052728495074709881270198835970389317941523857361850364017022304509376290207720256008405006732948566603224150355570649160734970971317472662883886886486338814746592921408393119181267181497570651798768021797205337230966145688421501488105679067409941062462734971969722385130944192813663982174957905597388266981965790521425259508395687922107614040885991691056092320226194800503374757179
e = 3
c = 31006276680299820175476315067101395202225288554778669509438887512651971587918750955037430926079670744122698892139964166907513659086428199

ct = 31006276680299820175476315067101395235456279784465349644746371087297187055640323870771651352163943015674692663683581458592537440630679864

X = int(floor(0.5 * pow(N, 1 / 9)))
m, n = 5, 9
R.<x> = PolynomialRing(ZZ)
f = ((x * X) ** 9) + (3 * c - 3 * ct) * ((x * X) ** 6) + (c ** 2 + 7 * c * ct + ct ** 2) * 3 * ((x * X) ** 3) + (c - ct) ** 3

def get_g(i, j):
    return ((N ** (m - i)) * ((x * X) ** j) * (f ** i))

#?IntegerMatrix
#?Matrix
#BaseMatrix = IntegerMatrix(m * n, m * n)

BaseMatrix = Matrix(m * n)
d = m
for i in range(m * n):
    c = m
    poly = get_g(m - d, i % n)
    #print(m - d, i % n, "AAAAAAAAAA")
    for j in range(m * n):
        if i == j:
            BaseMatrix[i, j] = (N ** c) * (X ** j)
            #print(c, "FFFFFFFFFFFFFFFFFFFFFFFFFFF")
        elif i < j:
            BaseMatrix[i, j] = 0
        elif i > j:
            BaseMatrix[i, j] = poly[j]
            #print(j, "VAVAVAVAVAVAVVAVA", poly[j])
        if j % n == n - 1:
            c -= 1
    if i % n == n - 1:
        d -= 1

print(det(BaseMatrix) == N ** ((m * (m + 1) * n) / 2) * X ** ((m * n * (m * n - 1)) / 2))

###################################################

#A = IntegerMatrix.from_matrix(BaseMatrix)

#dim = A.nrows
#print('dimension:', dim)

#M = GSO.Mat(A, float_type="d")
#M.update_gso()
#L = LLL.Reduction(M, delta=0.99, eta=0.501)
#L()

#print(M.B) # текущий базис решетки
#print('after:', [M.get_r(i, i) for i in range(dim)])

###################################################

ALLL = BaseMatrix.LLL(delta=0.9999, eta=0.5001, algorithm='fpLLL:proved')
AReduced = IntegerMatrix.from_matrix(ALLL)
short = SVP.shortest_vector(AReduced)
h = 0
for i in range(len(short)):
    h += (short[i] * ((x * X) ** i))
print(h.roots())

