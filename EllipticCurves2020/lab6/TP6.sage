def test_Prove_prime(p):
    Cert = Prove_prime(p)
    return Check_prime(p, Cert) == 'Accept'

def Miller_RabinTest(q):
  return True

def GenCurve(p):
  F = GF(p)
  while true:
    A = F.random_element()
    B = F.random_element()
    if gcd(4*A^3 + 27*B^2,p)!=1:
      continue
    E = EllipticCurve(F, [A, B])
    nPoints = E.order()
    if nPoints < p+1-floor(sqrt(p)) or nPoints > p + 1+ floor(sqrt(p)) or nPoints % 2 !=0 :
      continue
    q = nPoints // 2
    if q % 2 == 0 or q % 3 == 0:
      continue
    if (q.is_prime() == false): #TODO: run Miller_RabinTest(q)
      continue
    break
  return E, q


def FindPoint(E, q):
  Origin = E(0)
  while true:
    L = E.random_point()
    if q*L != Origin:
      continue
    break
  return L

def Prove_prime(p):
  """
  TESTS::
    sage: test_Prove_prime(1000003)
    True
    
    sage: test_Prove_prime(100000000003)
    True

  """
  flag_outer = true
  while flag_outer:
    i = 0
    p_list = [p]
    Curve_list = []
    Point_list = []
    while log(p_list[i],2) > 4:
      #print i, p_list, Curve_list, Point_list
      E, q = GenCurve(p_list[i])
      #print E, q
      L = FindPoint(E, q)
      #print L
      if q % 2 == 0 or q % 3 == 0:
        flag_outer = true
        break
      else:
        flag_outer = false
        i = i + 1
        p_list.append(q)
        Curve_list.append(E)
        Point_list.append(L)
    if p_list[i].is_prime() == false : # TODO: change to deterministic
      continue
    break
  return [p_list, Curve_list, Point_list]


def Check_prime(p, C):
  p_list, Curve_list, Point_list = C
  assert(len(p_list) == len(Curve_list)+1)
  assert(len(Curve_list) == len(Point_list))

  l = len(p_list)-1
  for j in range(l):
    if (p_list[j] % 2 ==0):
      print("p[", j,"] is divisible by 2 ")
      return "Reject"

    if (p_list[j] % 2 ==0):
      print("p[", j,"] is divisible by 3 ")
      return "Reject"

    if(gcd(Curve_list[j].discriminant(), p_list[j]) != 1):
      print("disc check fail at", j)
      return "Reject"

    #if(p_list[j+1] <= (pow(p_list[j], 1/4)+1)*(pow(p_list[j], 1/4)+1)):
    if (p_list[j+1] <= (pow(p_list[j], 1/4)+1)^2) and (p_list[j] > 37):
      print("p size fail at", j, "p[j] =", p_list[j])
      return "Reject"

    if (Point_list[j] == Curve_list[j](0)):
      print("infinity check fail at", j)
      return "Reject"

    if (p_list[j+1]*Point_list[j] != Curve_list[j](0)):
      print("scalar mult check fail at ", j)
      return "Reject"

  return "Accept"

#p = Primes().next(1000000)
#E, q = GenCurve(p)
#L = FindPoint(E, q)
#Cert = Prove_prime(p)
#print Cert
#           
#verif = certify(Cert[0], Cert[1], Cert[2])
#print verif


