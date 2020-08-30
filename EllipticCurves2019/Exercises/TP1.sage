
from sage.schemes.elliptic_curves.weierstrass_morphism import *

q = Primes().next(5)
F = Zmod(q)
R2.<x,y> = PolynomialRing(QQ,2)
R.<x,y> = GF(q)[]
Bound = 10^11


def jInvariant(a1, a2, a3, a4, a6, q):
  """
    Check is the curve y^2 + a1*x*y + a3*y = x^3 + a2*x^2 + a4*x+a6 is elliptic
    If yes, compute its j-invariant
    If no, raise an error
      :param a1, a2, a3, a4, a6: the coeffs of the input curve
      :param q: char=sise of the base field !!! Not tested if q is non-prime
    
    EXAMPLES::
    >>> jInvariant(1, 2, 1, 5, 1, 0)
    6128487/5329
    >>> jInvariant(1, 2, 1, 5, 1, 5)
    3
    >>> jInvariant(0, 1, 0, 0, 0, 0)
    Exception: the curve has a node
  """
  d2 = a1^2 + 4*a2
  d4 = 2*a4 + a1*a3
  d6 = a3^2+4*a6
  d8 = a1^2*a6+4*a2*a6-a1*a3*a4+a2*a3^2 - a4^2
  c4 = d2^2 - 24*d4
  disc = -(d2^2)*d8 - 8*(d4^3) - 27*d6^2 + 9*d2*d4*d6
  if q!=0:
    disc = mod(disc, q)
  if ((c4==0) and (disc ==0)):
    raise Exception("the curve has a cusp")
  if (disc ==0 ):
    raise Exception("the curve has a node")
  jInv = c4^3 *(1/disc)
  if q!=0:
    jInv = mod(jInv,q)
  return jInv


def randIsomorphic(a1, a2, a3, a4, a6, q):
  """
    If a_i's define an elliptic curve E, output the coeffs of a random curve isomorph to E over F_q
    or over QQ (if q = 0)
    :param a1, a2, a3, a4, a6: the coeffs of the input curve
    :param q: char (=size) of the base field !!! Not tested if q is non-prime
    
    EXAMPLES::
    >>> randIsomorphic(0, 1, 0, 0, 1, 0)
    [84018929351/40278291547, -3529590244531057273929/3244681539890263306418, 16968084280/65345114520434467921250200124323, 353286229108528897936/2631989573826162588039934597339577439997681, 428744830863529428921825964376141/273278975468076514722490246385165108162347501490379343657997333056]
    >>> randIsomorphic(1, 2, 1, 5, 1, 5)
    [6, 6, 5, 2, 5]
    >>> randIsomorphic(0, 0, 0, 0, 0, 5)
    Exception: the input curve is singular
    """
  try:
    jInv = jInvariant(a1, a2, a3, a4, a6, q)
  except:
    raise Exception("the input curve is singular")

  if q == 0: B = Bound
  else:      B = q-1
  
  u = ZZ.random_element(1,Bound)
  r = ZZ.random_element(0,Bound)
  s = ZZ.random_element(0,Bound)
  t = ZZ.random_element(0,Bound)
  
  #print [u, r, s, t]
  b1 = (1/u) * (a1+2*s)
  b2 = (1/u^2) * (a2 - s*a1+3*r-s^2)
  b3 = (1/u^3) * (a3+r*a1+2*t)
  b4 = (1/u^4) * (a4-s*a3+2*r*a2-(t+r*s)*a1 + 3*r^2 - 2*s*t)
  b6 = (1/u^6) * (a6+r*a4+r^2*a2+r^3-t*a3-t^2 - r*t*a1)
  if q!=0:
    b1 = mod(b1, q)
    b2 = mod(b2, q)
    b3 = mod(b3, q)
    b4 = mod(b4, q)
    b6 = mod(b6, q)
  return [b1, b2, b3, b4, b6]

#!!! UTTERLY SLOW IF q != 0 !!! TODO: FixIt
def isIsomorphic1(a1, a2, a3, a4, a6, b1, b2, b3, b4, b6, q):
  """
    If a_i's and b_i's define elliptic curves E1, E2, solve a system of non-lin. equations to find
    [u,r,s,t] over F_q / QQ that define an isomorphism btw. E1 and E2. It returns all the solution-tuples
    found and the number of the solutions
    
    
    :param a1, a2, a3, a4, a6: the coeffs of the input curve E1
    :param b1, b2, b3, b4, b6: the coeffs of the input curve E2
    :param q: char (=size) of the base field
    
    !!! Not tested if q is non-prime
    !!! Not implemnted for j_inv = 0, 1728
    
    EXAMPLES::
    >>> isIsomorphic(0,1,3,1,0,7706571724/19547240159, -133630307391190597856/3438851380502601107529, 52923479675/201660161417379101919146238171333, -510738511897151494016/11825698817184645424683867953329377420485841, 195487310213712167833665086975/40666820702883394956306193463183779725021510167778808819862996889,0)
    ([[u == -58641720477, r == 5803716513, s == -11559857586, t == -26461739839], [u == 58641720477, r == 5803716513, s == 11559857586, t == 26461739836]],
    2)
    >>> isIsomorphic(1, 1, 3, 2, 1, 4, 4, 1, 2, 1, 5)
    ([0], [0, 6, 3, 6])
    >>>  isIsomorphic(3, 1, 7, 9, 1, 1, 9, 5, 6, 1, 0)
    ([], 0)
    """
  
  try:
    jInv = jInvariant(a1, a2, a3, a4, a6, q)
    jInv = jInvariant(b1, b2, b3, b4, b6, q)
  except:
    raise Exception("one of the input curves is singular")

  u,r,s,t = var('u,r,s,t')
  eq1 = (u * b1 == a1+2*s)
  eq2 = (u^2*b2 == a2 - s*a1 + 3*r - s^2)
  eq3 = (u^3*b3 == a3+r*a1+2*t)
  eq4 = (u^4*b4 == a4-s*a3+2*r*a2-(t+r*s)*a1 + 3*r^2 - 2*s*t)
  eq5 = (u^6*b6 == a6+r*a4+r^2*a2+r^3-t*a3-t^2 - r*t*a1)
  
  if q==0:
    sol = solve([eq1, eq2, eq3, eq4, eq5], [u, r, s, t])
  else:
    sol = solve_mod([eq1, eq2, eq3, eq4, eq5], q)
  
  return sol, len(sol)

def isIsomorphicQQ(a1, a2, a3, a4, a6, b1, b2, b3, b4, b6, q):
  d2_E1 = a1*a1 + 4*a2
  d4_E1 = 2*a4 + a1*a3
  d6_E1 = a3*a3+4*a6
  c4_E1 = (d2_E1)^2 - 24*d4_E1
  c6_E1 = -(d2_E1)^3 + 36*(d2_E1 * d4_E1) - 216*d6_E1
  
  d2_E2 = b1^2 + 4*b2
  d4_E2 = 2*b4 + b1*b3
  d6_E2 = b3^2+4*b6
  c4_E2 = (d2_E2)^2 - 24*d4_E2
  c6_E2 = -(d2_E2)^3 + 36*(d2_E2 * d4_E2) - 216*d6_E2
  
  x = polygen(QQ, 'x')
  
  c_coeff = c6_E1 * c4_E2 / (c6_E2 * c4_E1)
  
  ulist = (x^2-c_coeff).roots(multiplicities=False)
  if len(ulist)==0:
    return "non-isomorphic"

  if len(ulist)>0:
    u = ulist[0]
    s = (b1*u - a1)/2
    r = (s*s + u*u*b2 - a2 + s*a1)/3
    t = (b3*u*u*u - a3 - r*a1)/2
  else:
    L.<alpha> = QQ.extension(x^2-c_coeff)
    u = alpha
    s = (b1*u - a1)/2
    r = (s*s + u*u*b2 - a2 + s*a1)/3
    t = (b3*u*u*u - a3 - r*a1)/2

  return ulist, [u, r, s, t]

def isIsomorphic(a1, a2, a3, a4, a6, b1, b2, b3, b4, b6, q):
  """
    If a_i's and b_i's define elliptic curves E1, E2, solve a system of non-lin. equations to find
    [u,r,s,t] over F_q / QQ that define an isomorphism btw. E1 and E2. It returns all the u's found and
    one tuple  [u,r,s,t] if there is at least one u.
    
    
    :param a1, a2, a3, a4, a6: the coeffs of the input curve E1
    :param b1, b2, b3, b4, b6: the coeffs of the input curve E2
    :param q: char (=size) of the base field
    
    !!! Not tested if q is non-prime
    !!! Not implemnted for j_inv = 0, 1728
    
    EXAMPLES::
    >>> isIsomorphic(0,1,3,1,0,7706571724/19547240159, -133630307391190597856/3438851380502601107529, 52923479675/201660161417379101919146238171333, -510738511897151494016/11825698817184645424683867953329377420485841, 195487310213712167833665086975/40666820702883394956306193463183779725021510167778808819862996889,0)
    ([58641720477, -58641720477],
    [58641720477, 5803716513, 11559857586, 26461739836])
    
    >>> isIsomorphic(0, 1, 3, 1, 2, 27, 18, 1, 43, 38, 53)
    ([48, 5], [48, 21, 12, 42])
    
    >>>  isIsomorphic(0,1,3,1,2,12,19,17,10,10, 53)
    'non-isomorphic'
    """
  
  try:
    jInvE1 = jInvariant(a1, a2, a3, a4, a6, q)
    jInvE2 = jInvariant(b1, b2, b3, b4, b6, q)
  except:
    raise Exception("one of the input curves is singular")

  if (jInvE1!=jInvE2):
    return "non-isomorphic"

  if (jInvE1 == 0) or (jInvE1 == 1728) or (jInvE2 == 0) or (jInvE2 == 1728):
    raise Exception("the function is not implemented for j-invariants = 0,1728")

  if q == 0:
    return isIsomorphicQQ(a1, a2, a3, a4, a6, b1, b2, b3, b4, b6, q)

  F = Zmod(q)

  d2_E1 = a1*a1 + 4*a2
  d4_E1 = 2*a4 + a1*a3
  d6_E1 = a3*a3+4*a6
  c4_E1 = (d2_E1)^2 - 24*d4_E1
  c6_E1 = -(d2_E1)^3 + 36*(d2_E1 * d4_E1) - 216*d6_E1

  d2_E2 = b1^2 + 4*b2
  d4_E2 = 2*b4 + b1*b3
  d6_E2 = b3^2+4*b6
  c4_E2 = (d2_E2)^2 - 24*d4_E2
  c6_E2 = -(d2_E2)^3 + 36*(d2_E2 * d4_E2) - 216*d6_E2

  x = polygen(F, 'x')

  c_coeff = F(c6_E1 * c4_E2 / (c6_E2 * c4_E1))

  ulist = (x^2-c_coeff).roots(multiplicities=False)
  if len(ulist)==0:
    return "non-isomorphic"

  print ulist

  if len(ulist)>0:
    u = ulist[0]
    s = (b1*u - a1)/2
    r = (s*s + u*u*b2 - a2 + s*a1)/3
    t = (b3*u*u*u - a3 - r*a1)/2

#check : if (u,r,s,t) indeed solve the system
#print (b1, (1/u)*(a1+2*s))
#print (b2, (1/u^2)*(a2 - s*a1+3*r-s*s))
#print (b3, (1/u^3)*(a3+r*a1+2*t))
#print (b4, (1/u^4)*(a4-s*a3+2*r*a2-(t+r*s)*a1 + 3*r^2 - 2*s*t))
#print (b6, (1/u^6)*(a6+r*a4+r^2*a2+r^3-t*a3-t^2 - r*t*a1))

# check : take a random point on E2, map it with [u,r,s,t], check that the result is in E1
    #y = polygen(F, 'y')
    #Px = ZZ.random_element(0,q-1)
    #Py_ = (y*y + b1*Px*y + b3*y - Px*Px*Px - b2*Px*Px - b4*Px - b6).roots(multiplicities=False)
    #while len(Py_) < 1:
    #  Px = ZZ.random_element(0,q-1)
    #  Py_ = (y*y + b1*Px*y+b3*y - Px*Px*Px - b2*Px*Px - b4*Px - b6).roots(multiplicities=False)
    #Py = Py_[0]
    #E2 = EllipticCurve(F, [b1, b2, b3, b4, b6])
    #P = [Px, Py]

    #Px_E1 = u*u*Px+r
    #Py_E1 = u*u*u*Py + u*u*s*Px + t


#print "is 0?:",  Py_E1 * Py_E1 + a1*Px_E1*Py_E1 + a3*Py_E1 - Px_E1*Px_E1*Px_E1 - a2*Px_E1*Px_E1 - a4*Px_E1 - a6

#no solutions over F, go higher
  else:
    L.<alpha> = F.extension(x^2-c_coeff)
    u = alpha
    s = (b1*u - a1)/2
    r = (s*s + u*u*b2 - a2 + s*a1)/3
    t = (b3*u*u*u - a3 - r*a1)/2
#check

# print (b1, (1/u)*(a1+2*s))
# print (b2, (1/u^2)*(a2 - s*a1+3*r-s*s))
# print (b3, (1/u^3)*(a3+r*a1+2*t))
# print (b4, (1/u^4)*(a4-s*a3+2*r*a2-(t+r*s)*a1 + 3*r^2 - 2*s*t))
#print (b6, (1/u^6)*(a6+r*a4+r^2*a2+r^3-t*a3-t^2 - r*t*a1))
#take a random point on E2 over the base field
#y = polygen(L, 'y')
#Px = ZZ.random_element(0,q-1) * alpha + ZZ.random_element(0,q-1)
#Py_ = (y*y + b1*Px*y+b3*y - Px*Px*Px - b2*Px*Px - b4*Px - b6).roots(multiplicities=False)
#while len(Py_) < 2:
#Px = ZZ.random_element(0,q-1) * alpha + ZZ.random_element(0,q-1)
#Py_ = (y*y + b1*Px*y+b3*y - Px*Px*Px - b2*Px*Px - b4*Px - b6).roots(multiplicities=False)
#Py = Py_[0]
#Px_E1 = u*u*Px+r
#Py_E1 = u*u*u*Py + u*u*s*Px + t

#print "is 0?:",  Py_E1 * Py_E1 + a1*Px_E1*Py_E1 + a3*Py_E1 - Px_E1*Px_E1*Px_E1 - a2*Px_E1*Px_E1 - a4*Px_E1 - a6
      
  return ulist, [u, r, s, t]


def findExtensionQQ(a1, a2, a3, a4, a6, b1, b2, b3, b4, b6, q):
  try:
    jInvE1 = jInvariant(a1, a2, a3, a4, a6, q)
    jInvE2 = jInvariant(b1, b2, b3, b4, b6, q)
  except:
    raise Exception("one of the input curves is singular")
  
  if (jInvE1!=jInvE2):
    return "curves have different j-invariant"
  
  if (jInvE1 == 0) or (jInvE1 == 1728) or (jInvE2 == 0) or (jInvE2 == 1728):
    raise Exception("the function is not implemented for j-invariants = 0,1728")

  d2_E1 = a1*a1 + 4*a2
  d4_E1 = 2*a4 + a1*a3
  d6_E1 = a3*a3+4*a6
  c4_E1 = (d2_E1)^2 - 24*d4_E1
  c6_E1 = -(d2_E1)^3 + 36*(d2_E1 * d4_E1) - 216*d6_E1
  
  d2_E2 = b1^2 + 4*b2
  d4_E2 = 2*b4 + b1*b3
  d6_E2 = b3^2+4*b6
  c4_E2 = (d2_E2)^2 - 24*d4_E2
  c6_E2 = -(d2_E2)^3 + 36*(d2_E2 * d4_E2) - 216*d6_E2
  
  x = polygen(QQ, 'x')
  
  c_coeff = c6_E1 * c4_E2 / (c6_E2 * c4_E1)
  
  ulist = (x^2-c_coeff).roots(multiplicities=False)
  
  if len(ulist)>0:
    u = ulist[0]
    s = (b1*u - a1)/2
    r = (s*s + u*u*b2 - a2 + s*a1)/3
    t = (b3*u*u*u - a3 - r*a1)/2
    return "E1, E2 are isomoirphic over the base field", [u,r,s,t]
  else:
    L.<alpha> = QQ.extension(x^2-c_coeff)
    u = alpha
    s = (b1*u - a1)/2
    r = (s*s + u*u*b2 - a2 + s*a1)/3
    t = (b3*u*u*u - a3 - r*a1)/2
    return "E1, E2 are isomoirphic over", L, [u,r,s,t]


# check isIsomorphic

def is_on_curve(Px, Py, a1, a2, a3, a4, a6, F):
  if (F(Py*Py +a1*Px*Py + a3*Py) == F(Px ** 3 + a2*Px*Px + a4*Px + a6)):
    return True
  return False

def check_function_isIsom(a1, a2, a3, a4, a6, b1, b2, b3, b4, b6, q, u, r, s, t):
  F = Zmod(q)
  E1 = EllipticCurve(F, [a1, a2, a3, a4, a6])
  E2 = EllipticCurve(F, [b1, b2, b3, b4, b6])
  P2 = E2.random_point()
  print 'trying on', P2
  x1 = F(u**2*P2[0]+r)
  y1 = F(u**3 * P2[1] + u**2 * s*P2[0]+t)
  return is_on_curve(x1, y1, a1, a2, a3, a4, a6, F)
  


def findExtension(a1, a2, a3, a4, a6, b1, b2, b3, b4, b6, q):
  """
    If a_i's and b_i's define elliptic curves E1, E2, solve a system of non-lin. equations to find
    [u,r,s,t] over F_q / QQ that define an isomorphism btw. E1 and E2.
    If q != 0 and no solution over F_q found, constructs an extension of F_q by adjoing a root of quadratic polynomial
    Similar for QQ.
    
    If the curves are isomorphic, the function returns one tuple  [u,r,s,t] either over the base field,
    or its quadratic extension
    
    
    :param a1, a2, a3, a4, a6: the coeffs of the input curve E1
    :param b1, b2, b3, b4, b6: the coeffs of the input curve E2
    :param q: char (=size) of the base field
    
    !!! Not tested if q is non-prime
    !!! Not implemnted for j_inv = 0, 1728
    
    EXAMPLES::
    >>> findExtension(0, 1, 3, 1, 2, 4, 48, 9, 16, 24, 53)
    ('E1, E2 are isomoirphic over the base field', [44, 8, 35, 4])
    
    >>> findExtension(0, 1, 3, 1, 2, 47, 45, 15, 39, 8, 53)
    
    ('E1, E2 are isomoirphic over',
    Univariate Quotient Polynomial Ring in alpha over Ring of integers modulo 53 with modulus alpha^2 + 5,
    [alpha, 51, 50*alpha, 42*alpha + 25])
    
    >>>  findExtension(1, 3, 0, 7, 11, 149285191107/32287120829, -5571517070849439150752/1042458171426445647241, 214924457885/33657972940024045898471277482789, -11715167770447055620209/1086719039173768740089384002472795410912081, 54783704351463028601416544457970/1132859142431390916000129067971120246444103784564827936191218521,0)
    ('E1, E2 are isomoirphic over the base field',
    [32287120829, 37979606869, 74642595553, 88472425508])
    
    
    """
  
  try:
    jInvE1 = jInvariant(a1, a2, a3, a4, a6, q)
    jInvE2 = jInvariant(b1, b2, b3, b4, b6, q)
  except:
    raise Exception("one of the input curves is singular")
  
  if (jInvE1!=jInvE2):
    return "curves have different j-invariant"
  
  if (jInvE1 == 0) or (jInvE1 == 1728) or (jInvE2 == 0) or (jInvE2 == 1728):
    raise Exception("the function is not implemented for j-invariants = 0,1728")

  if q == 0:
    return findExtensionQQ(a1, a2, a3, a4, a6, b1, b2, b3, b4, b6, q)

  d2_E1 = a1*a1 + 4*a2
  d4_E1 = 2*a4 + a1*a3
  d6_E1 = a3*a3+4*a6
  c4_E1 = (d2_E1)^2 - 24*d4_E1
  c6_E1 = -(d2_E1)^3 + 36*(d2_E1 * d4_E1) - 216*d6_E1
  
  d2_E2 = b1^2 + 4*b2
  d4_E2 = 2*b4 + b1*b3
  d6_E2 = b3^2+4*b6
  c4_E2 = (d2_E2)^2 - 24*d4_E2
  c6_E2 = -(d2_E2)^3 + 36*(d2_E2 * d4_E2) - 216*d6_E2
  
  x = polygen(F, 'x')
  
  c_coeff = F(c6_E1 * c4_E2 / (c6_E2 * c4_E1))
  
  ulist = (x^2-c_coeff).roots(multiplicities=False)

  if len(ulist)>0:
    u = ulist[0]
    s = (b1*u - a1)/2
    r = (s*s + u*u*b2 - a2 + s*a1)/3
    t = (b3*u*u*u - a3 - r*a1)/2
    return "E1, E2 are isomorphic over the base field", [u,r,s,t]
  else:
    L.<alpha> = F.extension(x^2-c_coeff)
    u = alpha
    s = (b1*u - a1)/2
    r = (s*s + u*u*b2 - a2 + s*a1)/3
    t = (b3*u*u*u - a3 - r*a1)/2
    return "E1, E2 are isomorphic over", L, [u,r,s,t]


a1 = 1
a2 = 3
a3 = 0
a4 = 7
a6 = 11

while True:
  b1 = ZZ.random_element(0,q-1)
  b2 = ZZ.random_element(0,q-1)
  b3 = ZZ.random_element(0,q-1)
  b4 = ZZ.random_element(0,q-1)
  b6 = ZZ.random_element(0,q-1)
  E1 = EllipticCurve(GF(q), [a1, a2, a3, a4, a6])
  E2 = EllipticCurve(GF(q), [b1, b2, b3, b4, b6])
  if (E1.j_invariant() == E2.j_invariant()):
    print b1, b2, b3, b4, b6
    break

print jInvariant(a1, a2, a3, a4, a6, q)
print [a1, a2, a3, a4, a6], [b1, b2, b3, b4, b6]
print isIsomorphic(F(a1), F(a2), F(a3), F(a4), F(a6), F(b1), F(b2), F(b3), F(b4), F(b6), q)

E1 = EllipticCurve(F, [a1, a2, a3, a4, a6])
E2 = EllipticCurve(F, [b1, b2, b3, b4, b6])
print isomorphisms(E1,E2)

print findExtension(F(a1), F(a2), F(a3), F(a4), F(a6), F(b1), F(b2), F(b3), F(b4), F(b6), q)

  #while True:
  #b1 = ZZ.random_element(1,10^4)
  #b2 = ZZ.random_element(0,10^4)
  #b3 = ZZ.random_element(0,10^4)
  #b4 = ZZ.random_element(1,10^4)
  #b6 = ZZ.random_element(1,10^4)
  #E1 = EllipticCurve([a1, a2, a3, a4, a6])
  #E2 = EllipticCurve([b1, b2, b3, b4, b6])
  #if (E1.j_invariant() == E2.j_invariant()):
  #  print b1, b2, b3, b4, b6
#  break
b1, b2, b3, b4, b6 = randIsomorphic(a1, a2, a3, a4, a6, 0)
print [a1, a2, a3, a4, a6], [b1, b2, b3, b4, b6]
print findExtension(a1, a2, a3, a4, a6, b1, b2, b3, b4, b6, 0)
