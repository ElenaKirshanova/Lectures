

q = Primes().next(34)
F = GF(q)

a = ZZ.random_element(1,q)
b = ZZ.random_element(1,q)

E = EllipticCurve(F, [a, b])
P1 = E.random_point()
P2 = E.random_point()

Pwrong = [ZZ.random_element(1,q), ZZ.random_element(1,q)]
print Pwrong, (Pwrong[1]*Pwrong[1] == (Pwrong[0])^3 - a*Pwrong[0] + b)

P1min=E([P1[0], -P1[1]])

Q = P1 + P2

print E, P1, P2
print Q

Infinity = E([0,1,0])

print Infinity + P1

print P1, P1min, P1 + P1min

P1Proj = E([P1[0]*2, P1[1]*2, P1[2]*2])
P2Proj = E([0, 1, 0])
P3Proj = P1Proj + P2Proj

print P1Proj, P2Proj, P3Proj

k = ZZ.random_element(1,q-1)
G = E.random_point()

print k, G, k*G, G.order(), (G.order())*G



