
################
# Для тестирования функции nTorsionPoints(n, a, b, q) 
# можно пользоваться встроенной функцией division_points(n).
#E = EllipticCurve(F, [a, b])
#Origin = E(0)
#Origin.division_points(n)
################

def test_nTorsionPoints(n, a, b, q):
  t1 = nTorsionPoints(n, a, b, q)
  if n==7:
    raise Exception(t1)
  F = t1[0][0].parent()
  E = EllipticCurve(F, [F(a),F(b)])
  t2 = [n*E(P) == E(0) for P in t1]
  return [len(set(t1)), len(set(t2)), t2[0]]

def nTorsion_extension_deg(n, a, b, q):
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
  # **** Place your code here *****


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
  # **** Place your code here *****