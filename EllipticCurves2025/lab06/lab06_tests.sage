def test_Prove_prime(p):
    Cert = Prove_prime(p)
    return Check_prime(p, Cert) == 'Accept'

def Check_prime(p, Cert):
    # **** Place your code here *****

def Prove_prime(p):
  """
  TESTS::
    sage: test_Prove_prime(1000003)
    True
    
    sage: test_Prove_prime(100000000003)
    True

  """
  # **** Place your code here *****