
#
p = Primes().next(1623)
E = EllipticCurve(GF(p), [1, 0])

N = E.order()
print E.is_supersingular()
print 'j', E.j_invariant()
print N, N.factor()
Origin = E(0)

def f(Px, a, b):
  return Px**3 + Px

def f2(Px):
  return 3*Px*Px + 1

def Velu(P, G, a, b):
  xcoo = P[0]
  ycoo = P[1]
  a_is = 0
  b_is = 0
  
  for i in range(len(G)):
    xcoo = xcoo+(P+G[i])[0] - G[i][0]
    ycoo = ycoo+(P+G[i])[1] - G[i][1]
  
    a_is = a_is + 3* G[i][0]**2 + a
    b_is = b_is + 5* G[i][0]**3 + 3*a*G[i][0] + 2*b
  
  
  #w = w + u
  a_is = (a - 5*a_is) % p
  b_is = (b - 7*b_is) % p
  return xcoo, ycoo, a_is, b_is




A = Origin.division_points(11)
B = Origin.division_points(37)

AnoO = []
BnoO = []
for i in xrange(len(A)):
  if A[i]!=Origin:
    AnoO.append(A[i])

for i in xrange(len(B)):
  if B[i]!=Origin:
    BnoO.append(B[i])

print AnoO
print BnoO

PA1 = AnoO[5]
#PA2 = AnoO[6]

PB1 = BnoO[2]
#PB2 = BnoO[3]

a = randint(1, 11)
Ta = a*PA1


b = randint(1, 37)
Tb = b*PB1

phi_A = Velu(PB1, AnoO, 1, 0)
print phi_A

phi_B = Velu(PA1, BnoO, 1, 0)
print phi_B

phi_A_check = EllipticCurveIsogeny(E, AnoO)
print phi_A_check, phi_A_check(PB1)

phi_B_check = EllipticCurveIsogeny(E, BnoO)
print phi_B_check, phi_B_check(PA1)

# Bob computes:

phiA_curve = EllipticCurve(GF(p),[phi_A[2],phi_A[3]])
assert(phiA_curve.is_supersingular())

print 'phiA_curve', phiA_curve
phi_A_point = phiA_curve([phi_A[0],phi_A[1]])
Tb1 = b*phi_A_point
print 'Tb1:', Tb1

#check
print 'compare with the above point', Velu(Tb, AnoO, 1, 0)


print Tb1.order()
Tb1Group = [Tb1]
for i in range(2, Tb1.order()):
  Tb1Group.append(i*Tb1)
#print Tb1Group
#print BnoO

EBob = Velu(Tb1, Tb1Group, phi_A[2],phi_A[3])
Bob_curve = EllipticCurve(GF(p),[EBob[2],EBob[3]])

EBob_check = EllipticCurveIsogeny(phiA_curve, Tb1Group)
print EBob, Bob_curve, Bob_curve.j_invariant()
print 'EBob_check', EBob_check, EBob_check(Tb1)

#EBob_check = EllipticCurveIsogeny(E, AnoO+BnoO)
#print EBob_check


# Alice computes:

phiB_curve = EllipticCurve(GF(p),[phi_B[2],phi_B[3]])
phi_B_point = phiB_curve([phi_B[0],phi_B[1]])
Ta1 = a*phi_B_point
print 'Ta1:', Ta1

#check
print Velu(Ta, BnoO, 1, 0)


print Ta1.order()
Ta1Group = [Ta1]
for i in range(2, Ta1.order()):
  Ta1Group.append(i*Ta1)

print Ta1Group

EAlice = Velu(Ta1, Ta1Group, phi_B[2],phi_B[3])
Alice_curve = EllipticCurve(GF(p),[EAlice[2],EAlice[3]])
print EAlice, Alice_curve, Alice_curve.j_invariant()

EAlice_check = EllipticCurveIsogeny(phiB_curve, Ta1Group)
print 'EAlice_check', EAlice_check


#Isogeny of degree 407 from Elliptic Curve defined by y^2 = x^3 + x over Finite Field of size 1627 to Elliptic Curve defined by y^2 = x^3 + 432*x + 1252 over Finite Field of size 1627


def is_on_curve(p, Px, Py, a, b):
  if ((Py*Py) % p == (pow(Px,3) + a*Px + b) % p):
    return True
  return False

# check Velu
E_check = EllipticCurve(GF(p), [3,1])

print E_check.order(), E_check.order().factor()
Origin = E_check(0)
A = Origin.division_points(11)
print A
P_check = A[1]
print len(A), P_check.order()

P_group = [P_check]
for i in range(2, P_check.order()):
  P_group.append(i*P_check)

Prand = E_check.random_point()

myV =  Velu(Prand,P_group, 3,1)
myCurve = EllipticCurve(GF(p), [myV[2],myV[3]])
myPoint = [myV[0], myV[1]]
phi_check = EllipticCurveIsogeny(E_check, P_group)
check_curve =phi_check.codomain()
print myV
print is_on_curve(p, myV[0], myV[1], myV[2], myV[3])
print check_curve(myV[0], myV[1])

print phi_check, phi_check(Prand)



print E_check.order()
print E_check.j_invariant(), EllipticCurve(GF(p), [myV[2],myV[3]]).j_invariant(), phi_check.codomain().j_invariant()


