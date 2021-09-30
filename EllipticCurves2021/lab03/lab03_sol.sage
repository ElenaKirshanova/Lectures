
q = Primes().next(52)
F = GF(q)

#a = ZZ.random_element(1,q)
#b = ZZ.random_element(1,q)
a = 2
b = 21
E = EllipticCurve(F, [a, b])
#print E


n = 5
psi = E.division_polynomial(n)

psi_roots = psi.roots(multiplicities=False)
Origin = E(0)

#nTorsionPoints = [Origin]
#for x in psi_roots:
#  if E.is_x_coord(x):
#    Q =E.lift_x(x)
#    nQ = n*Q
#    if (nQ == Origin):
#      nTorsionPoints.append(Q)
#      minQ = -Q
#      if (minQ != Q):
#        nTorsionPoints.append(minQ)

#print nTorsionPoints
#print "check", Origin.division_points(n)

psi_factors = psi.factor()
Fs    = [psi_factors[i] for i in range(len(psi_factors))]
Fdegs = [Fs[i][0].degree() for i in range(len(Fs))]
l = lcm(Fdegs)
f_star = 0
for i in range(len(Fdegs)):
  if (l % (2*Fdegs[i]) != 0):
    f_star =Fs[i][0]
    deg_f_star = f_star.degree()

Fext.<alpha> = F.extension(f_star)
allroots = f_star.roots(ring = Fext)
aroot =allroots[0][0]

ycoo = aroot ** 3 + a*aroot + b
c = Fext(ycoo.is_square())

if c == -1:
  d = 2*l
  print(d)
else:
  q_mod_n = Mod(q, n).multiplicative_order()
  d_star = lcm(q_mod_n, deg_f_star)
  print('d_star', d_star)
  if (d_star == l or l == d_star * n):
    d = l
    print('d==l', d)
  else:
    d = 2*l
    print('d==2*l', d)

### IF d ==f_star.degree(), can compute all torsion group

print("d: ", d, "f_star:", f_star, "f_star.degree(): ", f_star.degree())


E = EllipticCurve(Fext, [a, b])
print(E)
psi = E.division_polynomial(n)
psi_roots = psi.roots(multiplicities=False)
Origin = E(0)

def is_on_curve(Px, Py):
  if (Py*Py == Px ** 3 + a*Px + b):
    return True
  return False

def get_y_coo(xcoo):
  ycoo_ = xcoo ** 3 + a*xcoo + b
  if (kronecker(ycoo_.norm(), q) != -1):
    ycoos = sqrt(ycoo_, all=True)
  return ycoos

nTorsionPoints = [Origin]
for x in psi_roots:
  #if E.is_x_coord(x):
  if (x ** 3 + a*x + b).is_square():
    #Q =E.lift_x(x)
    ycoos = get_y_coo(x)
    for i in range(len(ycoos)):
      Q = E([x, ycoos[i]])
      nQ = n*Q
      if (nQ == Origin):
        nTorsionPoints.append(Q)
      #minQ = -Q
      #if (minQ != Q):
      #nTorsionPoints.append(minQ)

print(nTorsionPoints, len(nTorsionPoints))
print("check", Origin.division_points(n), len(Origin.division_points(n)))


def nTorsion_extension_deg(n, a, b, q, ret_fstar=False):
  """    
  TESTS::
    sage: nTorsion_extension_deg(3, 3, 17, 23)
    2

    sage: nTorsion_extension_deg(2, 1, 11, 41)
    1

    sage: nTorsion_extension_deg(5, 2, 21, 53)
    4

    sage: nTorsion_extension_deg(7, 1, 7, 11)
    21
  """
  F = GF(q)
  E = EllipticCurve(F, [a, b])
  
  psi = E.division_polynomial(n)
  psi_roots = psi.roots(multiplicities=False)
  Origin = E(0)

  psi_factors = psi.factor()
  Fs    = [psi_factors[i] for i in range(len(psi_factors))]
  Fdegs = [Fs[i][0].degree() for i in range(len(Fs))]

  l = lcm(Fdegs)
  f_star = 0
  for i in range(len(Fdegs)):
    if (l % (2*Fdegs[i]) != 0): # do not break if found, take FS with the largest degree
      f_star =Fs[i][0]
      deg_f_star = f_star.degree()

  Fext.<alpha> = F.extension(f_star)
  allroots = f_star.roots(ring = Fext)
  aroot = allroots[0][0]

  ycoo = aroot ** 3 + a*aroot + b
  c = Fext(ycoo.is_square())

  if c == -1:
    d = 2*l
    if ret_fstar:
      return d, f_star
    else:
      return d
  else:
    q_mod_n = Mod(q, n).multiplicative_order()
    d_star = lcm(q_mod_n, deg_f_star)
  #print 'd_star', d_star
    if (d_star == l or l == d_star * n):
      d = l
      #print('d==l', d, f_star)
      if ret_fstar:
        return d, f_star
      else:
        return d
    else:
      d = 2*l
      #print('d==2*l', d, f_star)
      return d

  return 'fail'


def get_y_coos(xcoo, a, b, q):
  ycoo_ = xcoo ** 3 + a*xcoo + b
  if (kronecker(ycoo_.norm(), q) != -1):
    ycoos = sqrt(ycoo_, all=True)
  return ycoos

def test_nTorsionPoints(n, a, b, q):
  t1 = nTorsionPoints(n, a, b, q)
  if n==7:
    raise Exception(t1)
  F = t1[0][0].parent()
  E = EllipticCurve(F, [F(a),F(b)])
  t2 = [n*E(P) == E(0) for P in t1]
  return [len(set(t1)), len(set(t2)), t2[0]]

def nTorsionPoints(n, a, b, q):
  """    
  TESTS::
    sage: test_nTorsionPoints(3, 3, 17, 23)
    [9, 1, True]

    sage: test_nTorsionPoints(2, 1, 11, 41)
    [4, 1, True]

    sage: test_nTorsionPoints(5, 2, 21, 53)
    [25, 1, True]

    sage: test_nTorsionPoints(7, 1, 7, 11)
    [49, 1, True]
  """

  F = GF(q)
  d, fstar = nTorsion_extension_deg(n, a, b, q, ret_fstar=True)
  #print('d, f_star.deg(): ', d, fstar.degree())

  #Fext.<alpha> = F.extension(f_star)
  if fstar.degree() > 1:
    Fext = F.extension(d)
    E = EllipticCurve(Fext, [a, b])
  else:
    E = EllipticCurve(F, [a, b])

  Origin = E(0)

  psi = E.division_polynomial(n)
  psi_roots = psi.roots(multiplicities=False)

  nTorsionPoints = [Origin]
  if n == 7:
    raise Exception(psi, psi.parent(), psi.factor(), "psi_roots =", psi_roots)
  for x in psi_roots:
    if (x ** 3 + a*x + b).is_square():
      ycoos = get_y_coos(x, a, b, q)
      for i in range(len(ycoos)):
        Q = E([x, ycoos[i]])
        nQ = n*Q #check
        if (nQ == Origin):
          nTorsionPoints.append(Q)

  return nTorsionPoints
