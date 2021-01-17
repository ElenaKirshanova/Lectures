p = Primes().next(1623)
E = EllipticCurve(GF(p), [1, 0])

Origin = E(0)

# 11-torsion group
A = Origin.division_points(11)

# 37-torsion group
B = Origin.division_points(37)


# remove inf from both
AnoO = []
BnoO = []
for i in range(len(A)):
  if A[i]!=Origin:
    AnoO.append(A[i])

for i in range(len(B)):
  if B[i]!=Origin:
    BnoO.append(B[i])


# get the generators
SA = AnoO[5]
SB = BnoO[2]
