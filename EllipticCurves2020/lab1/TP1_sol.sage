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


print findExtensionQQ(1,2,3,4,5, 23/7,-13/7,50/343,-4/2401,2031/117649, 0)
#y^2+x*y+3*y-x^3-2*x^2-(248904403*x)/16-2094318345083/64
print findExtensionQQ(1,2,3,4,5, 1,2,3,248904403/16,2094318345083/64, 0)