def Sum(a, b, q, x1, y1, x2, y2):
    """    
    TESTS::
        sage: Sum(3, 10, 11, 4, 3, 1, 5)
        [4, 8]

        sage: Sum(978, 8052, 10007, 5593, 1759, 1298, 1966)
        [3420, 5599]

        sage: Sum(37, 33, 59, 34, 11, 0, infinity)
        [34, 11]

        sage: Sum(17, 29, 59, 42, 14, 42, 45)
        [0, infinity]

        sage: Sum(14, 6, 23, 18, 8, 4, 12)
        Error: the point [4,12] is not on E
    """
    # your code here.

def SumProj(a, b, q, x1, y1, z1, x2, y2, z2):
    """    
    TESTS::
        sage: SumProj(57, 1, 59, 18, 29, 1, 5, 23, 1)
        [2,51,1]

        sage: SumProj(49, 41, 59, 57, 42, 1, 1, 0, 1)
        [57,42,1]
    """
    # your code here.

def Mul(a, b, q, x1, y1, k):
    """    
    TESTS::
        sage: Mul(15, 2, 23, 8, 6, 19)
        [10, 5]

        sage: Mul(16, 27, 37, 19, 30, 24)
        [0, infinity]

        sage: Mul(1596531425664112104, 8469635381684191285, 17364269638771469903, 13402180624743596496, 13385993554720361919, 4872114054757385562)
        [7833260487853357138, 12663396679974011624]
    """
    # your code here.
