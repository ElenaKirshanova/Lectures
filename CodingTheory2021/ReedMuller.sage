

# RM(2,4) example

F = GF(2)

r_param = 2
m_param = 4

n = 2^4
k = 11
G = matrix(F, k, n)
G[0] = [1]*n
G[1] = [0]*(2^3)+[1]*(2^3)
G[2] = [0]*(2^2)+[1]*(2^2)+[0]*(2^2)+[1]*(2^2)
G[3] = [0,0,1,1]*(4)
G[4] = [0,1]*(8)
G[5] = [G[1][i]*G[2][i] for i in range(n)]
G[6] = [G[1][i]*G[3][i] for i in range(n)]
G[7] = [G[1][i]*G[4][i] for i in range(n)]
G[8] = [G[2][i]*G[3][i] for i in range(n)]
G[9] = [G[2][i]*G[4][i] for i in range(n)]
G[10] = [G[3][i]*G[4][i] for i in range(n)]


print(G)

m = vector(F, k)
#m[3] = 1
#m[6] = 1
#m[8] = 1

m = vector(F, [0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0])

e = vector(F, n)
e[4] = 1
c = m*G
y = c+e

#print('c = ', c)
#print('y = ', y)


y = vector(F,[0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1])

#majority decoding

#Wb = Words(alphabet='01', length=2)
#for wb in Wb:
#	print(wb[0], wb[1])

#S = Subsets([0,1,2,3], 2)
#for s in S:
#	print(list(s))




t = r_param
Fpoly = y
P = vector(F, k)
while t>0:
	cvec = vector(F, k)
	#all subsets of size t
	Wb = Words(alphabet='01', length=m_param - t)
	Wa = Words(alphabet='01', length=t)
	S = Subsets([0,1,2,3], t)
	if t==2: ind_start = 5 #костыль
	if t==1: ind_start = 1
	for s in S:
		slist = list(s)
		score = 0
		s_ = {0,1,2,3}.difference(s)
		s_list = list(s_)
		print('s, s_:', s, s_)
		for wb in Wb:
			print('wb:', wb)

			a = vector(F, m_param)
			indb = 0
			for ind in range(m_param-t):
				a[s_list[ind]] = wb[indb]
				indb+=1

			suma = 0
			for wa in Wa:
				inda = 0
				for ind in range(t):
					a[slist[ind]] = wa[inda]
					inda+=1
				index=sum([int(a[i])*2^(m_param-i-1) for i in range(m_param)])
				suma += Fpoly[index]
				print('wa:', wa, 'a:', a, 'index:', index, 'suma:', suma)
			score+=ZZ(suma)

		index_cvec = ind_start
		if score>2^(m_param-t-1):
			cvec[index_cvec] = 1
		print('score:', score, 'cvec:', cvec, 'index_cvec:', index_cvec, 'value:', cvec[index_cvec])
		ind_start+=1

	Fpoly = Fpoly+cvec*G
	print('Fpoly:', Fpoly)
	P = P + cvec

	print('P:', P)


	t -=1



### EXAMPLES:

# y = (1, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 1)
# P = (1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0)
# c = (1, 1, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 1)
###############

# y = (0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 0)
# P = (0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0)
# c = (0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0)
###############

# y = (0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 1, 1, 0)
# P = (0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0)
# c = (0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0)
###############

# y = (0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 0, 0, 1, 1, 0)
# P = (0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0)
# c = (0, 0, 0, 0, 1, 0, 1, 0, 1, 1, 0, 0, 0, 1, 1, 0)
###############

# y = (1, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0)
# P = (1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0)
# c = (1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0)
###############

# y = (1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
# P = (1, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0)
# c = (1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
###############

# y = (0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1)
# P = (1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 0)
# c = (1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1)
###############

# y = (0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 0, 1, 1)
# P = (0, 1, 1, 1, 0, 0, 1, 0, 1, 0, 0)
# c = (0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1)
###############

# y = (1, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 1, 1, 0, 1, 0)
# P = (1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0)
# c = (1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 1, 0)
###############

# y = (1, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 1, 0)
# P = (1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1)
# c = (1, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0)
###############

# y = (0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 1)
# P = (0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 0)
# c = (0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 1)
###############



# RM(1,4) example
