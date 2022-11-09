def jInvariant(a1, a2, a3, a4, a6, q):
    """
    Check is the curve y^2 + a1*x*y + a3*y = x^3 + a2*x^2 + a4*x+a6 is elliptic
    If yes, compute its j-invariant
    If no, raise an error
      :param a1, a2, a3, a4, a6: the coeffs of the input curve
      :param q: char=size of the base field 

    !!! Not tested if q is non-prime
    
    TESTS::
        sage: jInvariant(1, 2, 1, 5, 1, 0)
        6128487/5329

        sage: jInvariant(1, 2, 1, 5, 1, 5)
        3

        sage: jInvariant(0, 1, 0, 0, 0, 0)
        Exception: the curve has a node
    """
    # your code here


def isIsomorphic(a1, a2, a3, a4, a6, b1, b2, b3, b4, b6, q):
    """
    If a_i's and b_i's define elliptic curves E1, E2, solve a system of non-lin. equations to find
    [u,r,s,t] over F_q / QQ that define an isomorphism btw. E1 and E2. It returns all the u's found and
    one tuple  [u,r,s,t] if there is at least one u.
    
    :param a1, a2, a3, a4, a6: the coeffs of the input curve E1
    :param b1, b2, b3, b4, b6: the coeffs of the input curve E2
    :param q: char (=size) of the base field
    
    !!! Not tested if q is non-prime
    !!! Not implemented for j_inv = 0, 1728
    
    TESTS::
        sage: isIsomorphic(0,1,3,1,0,7706571724/19547240159, -133630307391190597856/3438851380502601107529, 52923479675/201660161417379101919146238171333, -510738511897151494016/11825698817184645424683867953329377420485841, 195487310213712167833665086975/40666820702883394956306193463183779725021510167778808819862996889,0)
        ([58641720477, -58641720477],
        [58641720477, 5803716513, 11559857586, 26461739836])
        
        sage: isIsomorphic(0, 1, 3, 1, 2, 27, 18, 1, 43, 38, 53)
        ([48, 5], [48, 21, 12, 42])
        
        sage: isIsomorphic(0,1,3,1,2,12,19,17,10,10, 53)
        'non-isomorphic'
    """
    # your code here

def test_randIsomorphic(a1, a2, a3, a4, a6, q):
    if q == 0:
        E1 = EllipticCurve([a1, a2, a3, a4, a6])
    else:
        K = GF(q)
        E1 = EllipticCurve([K(a1), a2, a3, a4, a6])
    E2 = EllipticCurve(randIsomorphic(a1, a2, a3, a4, a6, q))
    return E1.is_isomorphic(E2)


def randIsomorphic(a1, a2, a3, a4, a6, q):
    """
    If a_i's define an elliptic curve E, output the coeffs of a random curve isomorphic to E over F_q
    or over QQ (if q = 0)
    :param a1, a2, a3, a4, a6: the coeffs of the input curve
    :param q: char (=size) of the base field !!! Not tested if q is non-prime
    
    TESTS::
        sage: test_randIsomorphic(0, 1, 0, 0, 1, 0)
        True

        sage: test_randIsomorphic(1, 2, 1, 5, 1, 5)
        True
        
        sage: randIsomorphic(0, 0, 0, 0, 0, 5)
        Exception: the input curve is singular
    """
    # your code here

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
    !!! Not implemented for j_inv = 0, 1728
    
    TESTS::
    sage: findExtension(0, 1, 3, 1, 2, 4, 48, 9, 16, 24, 53)
    ('E1, E2 are isomorphic over the base field', [44, 8, 35, 4])
    
    sage: findExtension(0, 1, 3, 1, 2, 47, 45, 15, 39, 8, 53)
    ('E1, E2 are isomorphic over', Univariate Quotient Polynomial Ring in alpha over Ring of integers modulo 53 with modulus alpha^2 + 5, [alpha, 51, 50*alpha, 42*alpha + 25])
    
    sage: findExtension(1, 3, 0, 7, 11, 149285191107/32287120829, -5571517070849439150752/1042458171426445647241, 214924457885/33657972940024045898471277482789, -11715167770447055620209/1086719039173768740089384002472795410912081, 54783704351463028601416544457970/1132859142431390916000129067971120246444103784564827936191218521,0)
    ('E1, E2 are isomorphic over the base field', [32287120829, 37979606869, 74642595553, 88472425508])

    sage: findExtension(1,2,3,4,5, 23/7,-13/7,50/343,-4/2401,2031/117649, 0)
    ('E1, E2 are isomorphic over the base field', [7, 13, 11, 17])

    sage: findExtension(1,2,3,4,5, 1,2,3,248904403/16,2094318345083/64, 0)
    ('E1, E2 are isomoirphic over', Number Field in alpha with defining polynomial x^2 - 1/2020, [alpha, -6057/8080, 1/2*alpha - 1/2, 3/4040*alpha - 18183/16160])
    """
    # your code here