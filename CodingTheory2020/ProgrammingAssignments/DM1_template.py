def hamming1511_enc(m):
	"""Return encoding of m.
		
		>>> hamming1511_enc([1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0])
		[0, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0]
		
		>>> hamming1511_enc([0, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1])
		[1, 1, 0, 0, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1]
		
		>>> hamming1511_enc([0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0])
		[1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0]
		
		
		"""




def hamming1511_dec(y):
	
	"""Return decoding of y together with the error position.
		
		>>> hamming1511_dec([1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0])
		([0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0], 8)
		
		>>> hamming1511_dec([1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0])
		([0, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0], 9)
		
		>>> hamming1511_dec([1, 0, 1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0])
		([0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0], 0)
		
		"""
	
		#YOUR CODE HERE

"""
if __name__ == '__main__':
	import doctest
	doctest.testmod()
"""
