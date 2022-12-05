from sage.misc.search import search
#q = Primes().next(1000000001)
#F = GF(q)

def bisectSearchSecond(L, el):
  low = 0
  high = len(L) - 1
  while low <= high:
    mid = (high+low) // 2
    midval = L[mid][1]  # comapare the second component of L
    if  midval < el:
      low = mid + 1
    elif midval > el:
      high = mid - 1
    else:
      return True, mid
  return False, mid

def orderP_multiple(E, P1, q):
  Q = (q+1)*P1
  m = ceil(pow(q, 1.0/4))
  
  #print(m)
  
  # baby steps
  L = [[1,P1[0]]]
  for j in range(2, m+1):
    jP1 = j*P1
    if Q[0]==jP1[0]:  # checking k=0 in the first loop
      if Q[1] == jP1[1]:
        M = q+1 - j
      else:
        M = q+1+j
      #print('k = 0!')
      return M
    L.append([j,(j*P1)[0]])

  # sort wrt x-coo
  L.sort(key=lambda x: x[1])


  twicemP = 2*m*P1
  M = 0
  P_plus = Q
  P_minus = Q

  for k in range(1,m+1):
    # Q + k*(2m)P
    P_plus = P_plus + twicemP
    search_result = bisectSearchSecond(L, P_plus[0])
    if search_result[0]:
      #check the y - coo
      jP1 = (L[search_result[1]][0])*P1
      if jP1[1] == P_plus[1]: #  '+' sign
        M = q + 1 + 2*m*k - L[search_result[1]][0]
        #print(M)
        return M
      else: #  '-' sign
        M = q + 1 + 2*m*k + L[search_result[1]][0]
        #print(M)
        return M

    # Q - k*(2m)P
    P_minus = P_minus - twicemP
    search_result = bisectSearchSecond(L, P_minus[0])
    if search_result[0]:
      #check the y - coo
      jP1 = (L[search_result[1]][0])*P1
      if jP1[1] == P_minus[1]: #  '+' sign
        M = q + 1 - 2*m*k  - L[search_result[1]][0]
        #print(L[search_result[1]][0], 2*m*k)
        #print(M)
        return M
      else: #  '-' sign
        M = q + 1 - 2*m*k  + (L[search_result[1]][0])
        #print(L[search_result[1]][0], 2*m*k)
        #print(M)
        return M
  return 'fail'


def orderP(E, P1, q):
  M = orderP_multiple(E, P1, q)
  #print'asserting M!= fail'
  assert(M!='fail')
  Infinity = E(0)
  #print'asserting M*P1 = 0...'
  assert(M*P1 == Infinity)
  Mfactors = list(M.factor())

  for i in range(len(Mfactors)):
    B = Mfactors[i][1]
    while B > 0:
      if ( int (M /Mfactors[i][0]) *P1 == Infinity):
        B = B - 1
        M = int(M/Mfactors[i][0])
      else:
        break;
  return M



#a = ZZ.random_element(1,q-1)
#b = ZZ.random_element(1,q-1)
#E = EllipticCurve(F, [a, b])
#q = Primes().next(10001)
#a = 7087
#b = 5152
#E = EllipticCurve(F, [a, b])
#print(E)


def test_orderBSGS(i):
  q = Primes().next(2^(16*i) + 1)
  a = ZZ.random_element(1,q-1)
  b = ZZ.random_element(1,q-1)
  F = GF(q)
  E = EllipticCurve(F, [a, b])
  #o = orderBSGS(a,b,q)
  #assert o == E.order(), [o, E.order()]
  return orderBSGS(a,b,q) == E.order()

def orderBSGS(a, b, q):
  """
  TESTS::
    sage: [test_orderBSGS(i) for i in range(1,5)]
    [True, True, True, True]
  """
  E = EllipticCurve(GF(q), [a, b])
  # number of random points to choose
  N = ceil(4*ln(q))
  L = 1
  for i in range(N):
    P = E.random_point()
    ordP = orderP(E, P, q)
    #print'asserting ordP = P.order()...',  ordP, P.order()
    #assert(ordP == P.order())
    L = lcm(L,ordP)
    if (L >= 4*sqrt(q) and L < q+ 1 - 2*sqrt(q)):
      multiple = (q+1+ round(2*sqrt(q)) ) // L
      #print'asserting interval of L...', L*multiple, round(q + 1 - 2*sqrt(q))
      assert(L*multiple >= q + 1 - 2*sqrt(q) and L*multiple <= q+ 1 + 2*sqrt(q))
      return L*multiple
    elif (L >= q+ 1 - 2*sqrt(q)):
      return L
    return 'fail'


#print(orderBSGS(a,b,q))

