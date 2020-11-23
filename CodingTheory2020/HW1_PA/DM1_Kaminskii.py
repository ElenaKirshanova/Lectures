import operator as op
from functools import reduce

def procbit(ind, message):
	s = 0
	if ind == 0:
		for i in message[1:]:
			s +=i
	elif ind == 1:
		return sum(message[3::2]) % 2
	elif ind == 2:
		for i in [3, 6, 7, 10, 11, 14, 15]:
			s += message[i]
	elif ind == 4:
		for i in [5, 6, 7, 12, 13, 14, 15]:
			s += message[i]
	elif ind == 8:
		for i in [9, 10, 11, 12, 13, 14, 15]:
			s += message[i]
	return s % 2



def hamming1511_enc(message):
	"""Return encoding of m.
		
		>>> hamming1511_enc([1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0])
		[0, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0]
		
		>>> hamming1511_enc([0, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1])
		[1, 1, 0, 0, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1]
		
		>>> hamming1511_enc([0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0])
		[1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0]
		
		
		"""
	c = message
	for i in [0, 1, 2, 4, 8]:
		c.insert(i, 0)
	for i in [0, 1, 2, 4, 8]:
		c[i] = procbit(i, c)
	return c



def hamming1511_dec(coded):
	
	"""Return decoding of y together with the error position.
		
		>>> hamming1511_dec([1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0])
		([0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0], 8)
		
		>>> hamming1511_dec([1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0])
		([0, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0], 9)
		
		>>> hamming1511_dec([1, 0, 1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0])
		([0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0], 0)
		
		"""
	
		#YOUR CODE HERE
	t = coded
	k = reduce(op.xor, [i for i, bit in enumerate(t) if bit])
	t[k] += 1
	t[k] %= 2
	for i in [8, 4, 2, 1, 0]:
		t.pop(i)
	return t, k

if __name__ == '__main__':
	import doctest
	doctest.testmod()

