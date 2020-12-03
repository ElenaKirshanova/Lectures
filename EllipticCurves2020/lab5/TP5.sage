
q = Primes().next(8382093480298834)
p = Primes().next(833489843)

#print 'p:', p

N = p*q
#N = 100181800505809010267
ZN = IntegerModRing(N)

#B1 = round(pow(N, 1/2))
B1 = 20000000089*10
#B1 = 833489857
B2 = B1

A = ZN.random_element()
x = ZN.random_element()
y = ZN.random_element()
B = ZN(y^2 - x^3 - A*x)


#A = 20394962173970
#B = 45111734092462
#x = 16372128041009
#y = 43812153295794

disc = 4*pow(A,3) + 27*pow(B,2)
assert( gcd(disc, N) == 1)


def is_on_curve(N, Px, Py, a, b):
  #ZN = IntegerModRing(N)
  if ((Py*Py) == (Px ** 3 + a*Px + b)):
    return True
  return False

E = EllipticCurve(ZN, [A, B])
#print(E)
assert( is_on_curve(ZN, x, y, A, B))

def mySum(x1, y1, x2, y2, N, A):
  ZN = IntegerModRing(N)
  if (x1 == infinity):
    return x2, y2
  if (x2 == infinity):
    return x1, y1

  if (ZN(x1)==ZN(x2)) and (ZN(y1) == ZN(-y2) ):
    return infinity

  if (ZN(x1)!=ZN(x2)):
    d = gcd(x1 - x2, N)
    if (d!=1) and (d!=N):
      #print 'non trivial:', d
      return  d, 'divisor'
    alpha = ZN (y2-y1)/ ZN(x2-x1)

  if (ZN(x1)==ZN(x2)):
    d = gcd(y1 + y2, N)
    if d>1:
      #print 'non trivial:', d
      return d, 'divisor'
    alpha = ZN (3*x1*x1+A) / ZN(y1+y2)

  beta = ZN(y1-alpha*x1)
  x3 = ZN(alpha*alpha - x1 - x2)
  y3 = ZN(-(alpha*x3 + beta))
  return x3, y3

def fastScalar(x1, y1, k, N, A):
  k_bits = k.binary()
  Q = x1, y1
  j = 1
  while j<len(k_bits):
    if (k_bits[j] == '1'):
      Q = mySum(Q[0], Q[1], Q[0], Q[1], N, A)
      Q = mySum(x1, y1, Q[0], Q[1], N, A)
    else:
      Q = mySum(Q[0], Q[1], Q[0], Q[1], N, A)
    
    #print j, k_bits[j], Q
    j = j+1
  return Q

def fastScalarRL(x1, y1, k, N, A):
  k_bits = k.binary()
  Q1 = x1, y1
  if (k_bits[len(k_bits)-1] == '1'):
    Q = Q1
  else:
    Q = infinity, infinity
  j = len(k_bits)-2
  while j>=0:
    Q1 = mySum(Q1[0], Q1[1], Q1[0], Q1[1], N, A)
    if Q1[1] == 'divisor': return Q1[0]
    if (k_bits[j] == '1'):
      if (Q[0]==infinity):
        Q = Q1
      else:
        Q = mySum(Q[0], Q[1], Q1[0], Q1[1], N, A)
        if Q[1] == 'divisor': return Q[0]
    j = j-1
  return Q

#def ScalarMul(x1, y1, k, N, A):
#  if (k == 1):
#   return x1, y1
#  if (k==0):
#    return infinity, infinity
#  if (k % 2 == 0):
#    return mySum(ScalarMul(x1, y1, k//2, N, A), ScalarMul(x1, y1, k//2, N, A), N, A)
#  else:
#    return mySum(x1, y1, ScalarMul(x1, y1, k-1, N, A), N, A)





P = E([x,y])
#print 'P:', P
p_prime = 2

#print 'P:', P
#scalar = 6073
#scalar = 7
#print 'fastScalar:', fastScalar(P[0], P[1], scalar, N, A)
#print 'fastScalarRL:', fastScalarRL(P[0], P[1], scalar, N, A)
#print 'ScalarMul:', ScalarMul(P[0], P[1], scalar, N, A)
#print 'scalar*P:', scalar*P


#while p_prime < B1:
#  exponent = floor(log(B2)/log(p_prime))
#  assert(pow(p_prime, exponent)<B2)
#  try:
#    P = pow(p_prime, exponent)*P
#  except:
#    print 'fastScalarRL:', fastScalarRL(P[0], P[1], pow(p_prime, exponent), N, A)
#    break;
#print pow(p_prime, exponent)*P
#  p_prime = Primes().next(p_prime)

def factorECM(N):
  """
  TESTS::
    sage: factorECM(100070000190133)
    [10007, 10000000019]

    sage: factorECM(100181800505809010267)
    [5009090003, 20000000089]

    sage: factorECM(6986389896254914969335451)
    [833489857, 8382093480298843]
  """
  ZN = IntegerModRing(N)
  Ntrials = 15
  for i in range(Ntrials):
    #print i
    # get a curve and a point on it
    A = ZN.random_element()
    x = ZN.random_element()
    y = ZN.random_element()
    B = ZN(y^2 - x^3 - A*x)
    E = EllipticCurve(ZN, [A, B])
    disc = 4*pow(A,3) + 27*pow(B,2)
    if( gcd(disc, N) != 1):
      return sorted([lift(gcd(disc, N)), N / lift(gcd(disc, N))])
    assert( is_on_curve(N, x, y, A, B))
    P = E([x,y])

    #check all the primes up to B1
    p_prime = 2
    while p_prime < sqrt(B1):
      #print p_prime
      exponent = floor(log(B2)/log(p_prime))
      try: assert(pow(p_prime, exponent)<B2)
      except: 'fail pow(p_prime, exponent)<B2'
      try:
        P = pow(p_prime, exponent)*P
      except:
        #print pow(p_prime, exponent)*P
        q = fastScalarRL(P[0], P[1], pow(p_prime, exponent), N, A)
        return sorted([lift(q), N/lift(q)]) 
      p_prime = Primes().next(p_prime)
    return 'no non-trivial divisor found'

#print(N)
#print('factorECM:', factorECM(17*19))


