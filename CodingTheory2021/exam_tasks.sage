H = matrix(GF(5), [[1,2,0,1,4],[3,1,1,2,1]])
G = matrix(H.transpose().kernel().basis())
print(H.rank())
print(G)

x = vector(GF(5),[0,0,1,2,2])
print(H*x)

x = vector(GF(5),[1,0,1,0,2])
print(H*x)

x = vector(GF(5),[4,4,3,1,0])
print(H*x)

x = vector(GF(5),[2,3,0,1,1])
print(H*x)

print("-----------------------")
#-----------------------
H = matrix(GF(2),[[0,1,1,1,0],[1,0,1,0,1]])
G = matrix(GF(2),[[1,1,1,0,0],[0,1,0,1,0],[1,0,0,0,1]])
G1 = matrix(GF(2),[[1,0,0,0,1],[0,1,0,1,0],[0,0,1,1,1]])
print(H*G.transpose())
print(H*G1.transpose())
print("-----------------------")
#-----------------------
H = matrix(GF(2),[[1,0,1,1,1],[0,0,1,0,1],[0,1,1,1,0]])
print("H:", H)
print(H.rank())
print("H:", H.echelon_form())

G = matrix(H.transpose().kernel().basis())
print("G:", G)
c = vector(GF(2),[0,1])*G
print('c:', c)
e = vector(GF(2),[0,0,1,0,0])
y = c+e
print(y)

print(H*y, H*e)
