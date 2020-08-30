
q = Primes().next(20)
F = GF(q)

#a = ZZ.random_element(1,q)
#b = ZZ.random_element(1,q)
a = 3
b = 17
E = EllipticCurve(F, [a, b])

n = 7
psi = E.division_polynomial(n)
psi_factors = psi.factor()

Fs    = [psi_factors[i] for i in range(len(psi_factors))]
Fdegs = [Fs[i][0].degree() for i in range(len(Fs))]


l = lcm(Fdegs)
print "l:", l

f_star = 0
for i in range(len(Fdegs)):
  if (l % (2*Fdegs[i]) != 0):
    f_star =Fs[i][0]
    deg_f_star = f_star.degree()
#break;

if f_star == 0:
  raise ValueError("f_star is not set")

print psi
print Fs
print Fdegs
print f_star, deg_f_star


print "f_star.roots()", f_star.roots()

Fext.<alpha> = F.extension(f_star)
allroots = f_star.roots(ring = Fext)

aroot =allroots[0][0]

print allroots, aroot
ycoo = aroot ** 3 + a*aroot + b
c = kronecker(ycoo.norm(), q)
#print c

if c == -1:
  d = 2*l
  print d
else:
  q_mod_n = Mod(q, n).multiplicative_order()
  d_star = lcm(q_mod_n, deg_f_star)
  print 'd_star', d_star
  if (d_star == l or l == d_star * n):
    d = l
    print 'd==l', d
  else:
    d = 2*l
    print 'd==2*l', d

#print "E.torsion_order()", E.torsion_order()


#----- get all torsion points -----

allTorsionPoints_baseField = []
allTorsionPoints_ext = []
ExtensionFields = []
non_squares_in_base = []

for i in range(len(Fs)):
  fi = Fs[i][0]
  
  # if degree==1 -> we already have a candidate for the x coo
  # remains to check if it's a square in F_q
  if fi.degree() == 1:
    xcoo = fi.roots()[0][0]
    ycoo_ = xcoo ** 3 + a*xcoo + b
    print fi, 'kron base:', F(ycoo_).is_square()
      #if (kronecker(ycoo_, q) != -1):
    if ( F(ycoo_).is_square()):
      ycoos = sqrt(ycoo_, all=True)
      print ycoos
      for j in range(len(ycoos)):
        allTorsionPoints_baseField.append([xcoo, ycoos[j]])
    else: # ycoo_ may not be a square in Fq, but it may be a square in Fext
      non_squares_in_base.append([xcoo, ycoo_])

  print "allTorsionPoints_baseField", allTorsionPoints_baseField


  #else construct the extension field, take all the roots, check for the square
  if fi.degree() > 1:
    Fext.<alpha> = F.extension(fi)
    ExtensionFields.append(Fext)
    
  
    E = EllipticCurve(Fext, [a, b]) # for check only
    Origin = E(0)
    print "Origin.division_points(n):", Origin.division_points(n), len(Origin.division_points(n))
    
    if len(non_squares_in_base)>0:
      print 'non_squares_in_base:', non_squares_in_base
      for j in range(len(non_squares_in_base)):
        xcoo = Fext(non_squares_in_base[j][0])
        ycoo_ = xcoo ** 3 + a*xcoo + b
        #c = kronecker(ycoo_.norm(), q)
        c = Fext(ycoo_.is_square())
        print 'kron base to ext:', c
        if c:
          ycoos = sqrt(ycoo_, all=True)
          for k in range(len(ycoos)):
            allTorsionPoints_ext.append([xcoo, ycoos[k]])
            #check the points obtained from the polynomial fi
            P = E([xcoo, ycoos[k]])
            print P
    
    allroots = fi.roots(ring = Fext)
    print " fi.roots: ", allroots
    for j in range(len(allroots)):
      xcoo = allroots[j][0]
      ycoo_ = xcoo ** 3 + a*xcoo + b
      c = Fext(ycoo_.is_square())
      print xcoo, ' kron ext', c
      if c:
        ycoos = sqrt(ycoo_, all=True)
        for k in range(len(ycoos)):
          allTorsionPoints_ext.append([xcoo, ycoos[k]])
           #check the points obtained from the polynomial fi
          P = E([xcoo, ycoos[k]])
          print P
      print "|allTorsionPoints_ext|", len(allTorsionPoints_ext)






print "ExtensionFields:", ExtensionFields
print "allTorsionPoints_baseField", allTorsionPoints_baseField
print "allTorsionPoints_ext:", allTorsionPoints_ext, len(allTorsionPoints_ext)


E = EllipticCurve(F, [a, b])
Origin = E(0)
print "allTorsionPoints_baseField check:", Origin.division_points(n)


def is_on_curve(Px, Py, a, b):
  if (Py*Py == Px ** 3 + a*Px + b):
    return True
  return False

for i in range(len(allTorsionPoints_baseField)):
  if not is_on_curve(allTorsionPoints_baseField[i][0], allTorsionPoints_baseField[i][1], a, b):
    print "a point in E[n] is not on E"
  P = E(allTorsionPoints_baseField[i])
#print P, n*P

for i in range(len(allTorsionPoints_ext)):
  if not is_on_curve(allTorsionPoints_ext[i][0], allTorsionPoints_ext[i][1], a, b):
    print "a point in E[n] is not on E"
  P = E(allTorsionPoints_ext[i])
#print P, n*P


#E = EllipticCurve(ExtensionFields[2], [a, b])
#Origin = E(0)
#print "allTorsionPoints_ext check",  Origin.division_points(n)

#E = EllipticCurve(ExtensionFields[0], [a, b])
#Origin = E(0)
#print "allTorsionPoints_ext check",  Origin.division_points(n)

#E = EllipticCurve(ExtensionFields[1], [a, b])
#Origin = E(0)
#print "allTorsionPoints_ext check",  Origin.division_points(n)


#---------- nTorsion_extension_deg ----------

def nTorsion_extension_deg(a, b, q, n):
  F = GF(q)
  E = EllipticCurve(F, [a, b])
  psi = E.division_polynomial(n)
  psi_factors = psi.factor()

  Fs    = [psi_factors[i] for i in range(len(psi_factors))]
  Fdegs = [Fs[i][0].degree() for i in range(len(Fs))]

  l = lcm(Fdegs)
  #print "l:", l

  f_star = 0
  for i in range(len(Fdegs)):
    if (l % (2*Fdegs[i]) != 0):
      f_star =Fs[i][0]
      deg_f_star = f_star.degree()
      #break;

  if f_star == 0:
    raise ValueError("f_star is not set")

  #print "f_star:", f_star, deg_f_star
  #print "f_star.roots()", f_star.roots()

  Fext.<alpha> = F.extension(f_star)
  allroots = f_star.roots(ring = Fext)

  aroot =allroots[1][0] #take the x-coo of the second root (assume deg_f_star>=2)

  ycoo = aroot ** 3 + a*aroot + b
  c = kronecker(ycoo.norm(), q)

  if c == -1:
    d = 2*l
# print d
  else:
    q_mod_n = Mod(q, n).multiplicative_order()
    d_star = lcm(q_mod_n, deg_f_star)
#print 'd_star', d_star
    if (d_star == l or l == d_star * n):
      d = l
#print 'd==l', d
    else:
      d = 2*l
#print 'd==2*l', d
  return d


def nTorsionPoints(a, b, q, n):
  
  F = GF(q)
  E = EllipticCurve(F, [a, b])
  psi = E.division_polynomial(n)
  psi_factors = psi.factor()
  
  Fs    = [psi_factors[i] for i in range(len(psi_factors))]

  allTorsionPoints_baseField = []
  allTorsionPoints_ext = []
  ExtensionFields = []

  for i in range(len(Fs)):
    fi = Fs[i][0]
  
    # if degree==1 -> we already have a candidate for the x coo
    # remains to check if it's a square in F_q
    if fi.degree() == 1:
      xcoo = fi.roots()[0][0]
      ycoo_ = xcoo ** 3 + a*xcoo + b
      if (kronecker(ycoo_, q) != -1):
        ycoos = sqrt(ycoo_, all=True)
        for j in range(len(ycoos)):
          allTorsionPoints_baseField.append([xcoo, ycoos[j]])

    #else construct the extension field, take all the roots, check for the square
    else:
      Fext.<alpha> = F.extension(fi)
      ExtensionFields.append(Fext)
      allroots = fi.roots(ring = Fext)
      for j in range(len(allroots)):
        xcoo = allroots[j][0]
        ycoo_ = xcoo ** 3 + a*xcoo + b
        c = kronecker(ycoo_.norm(), q)
        if (c!=-1):
          ycoos = sqrt(ycoo_, all=True)
          for k in range(len(ycoos)):
            allTorsionPoints_ext.append([xcoo, ycoos[k]])
            #check the points obtained from the polynomial fi
            P = E([xcoo, ycoos[k]])
    print allTorsionPoints_ext

    return allTorsionPoints_baseField, allTorsionPoints_ext
