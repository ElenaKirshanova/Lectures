import socketserver
import sys
import re
import os

import base64
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives.serialization import Encoding
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives.ciphers.algorithms import Camellia

# secp256r1
p = 0xffffffff00000001000000000000000000000000ffffffffffffffffffffffff
a = 0xffffffff00000001000000000000000000000000fffffffffffffffffffffffc
b = 0x5ac635d8aa3a93e7b3ebbd55769886bc651d06b0cc53b0f63bce3c3e27d2604b
P = (0x6b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c296, 0x4fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5)
n = 0xffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc632551
iv = os.urandom(16)
pirozhok = os.urandom(10).hex()

print(f"pirozhok: {pirozhok}")

curve = ec.SECP256R1()

def encrypt(msg, key, iv):
    cipher = Cipher(Camellia(key), modes.OFB(iv))
    encryptor = cipher.encryptor()
    msg = bytes(msg, 'utf-8')
    ct = encryptor.update(msg) + encryptor.finalize()
    return base64.b64encode(ct)

def decrypt(msg, key, iv):
    cipher = Cipher(Camellia(key), modes.OFB(iv))
    decryptor = cipher.decryptor()
    msg = base64.b64decode(msg)
    msg = decryptor.update(msg) + decryptor.finalize()
    return msg


class MyTCPHandler(socketserver.StreamRequestHandler):

    def handle(self):
        print(f"{self.client_address[0]} connected ...")
        self.wfile.write(bytes("Public parameters: p, a, b, P, n, iv\n", 'utf-8'))
        self.wfile.write(bytes(str(p)+"\n", 'utf-8'))
        self.wfile.write(bytes(str(a)+"\n", 'utf-8'))
        self.wfile.write(bytes(str(b)+"\n", 'utf-8'))
        self.wfile.write(bytes(str(P)+"\n", 'utf-8'))
        self.wfile.write(bytes(str(n)+"\n", 'utf-8'))
        self.wfile.write(bytes(str(iv)+"\n", 'utf-8'))
        
        private_key = ec.generate_private_key(curve)
        print(f"Server private_key: {private_key.private_numbers().private_value}")
        public_key = private_key.public_key()
        self.wfile.write(bytes("Server public key: Q\n", 'utf-8'))
        Q = (public_key.public_numbers().x, public_key.public_numbers().y)
        self.wfile.write(bytes(f"{Q}\n", 'utf-8'))
        self.wfile.write(bytes("Enter your public key:\n", 'utf-8'))
        data = bytes.decode(self.rfile.readline().strip())
        print(f"data = {data}")
        x, y = list(filter(None, re.split("[\(,\) ]", data)))
        try:
            peer_public_key = ec.EllipticCurvePublicNumbers(int(x.strip()), int(y.strip()), curve).public_key()
        except Exception as e:
            self.wfile.write(bytes(f"Error: {e}\n", 'utf-8'))
            return

        shared_key = private_key.exchange(ec.ECDH(), peer_public_key)
        #shared_key = int.from_bytes(shared_key, "big")
        print(f"Shared key: {shared_key}")
        #shared_key = int(shared_key).to_bytes(len(p.binary())/8, "big")
        msg = encrypt(f"What is the best operating system?\nSend me a space-separated OS name and the pirozhok: {pirozhok}", shared_key, iv)
        self.wfile.write(bytes(f"Message from server:\n", 'utf-8'))
        self.wfile.write(msg)
        self.wfile.write(bytes(f"\n", 'utf-8'))
        self.wfile.write(bytes(f"Your answer:\n", 'utf-8'))
        data = bytes.decode(self.rfile.readline().strip())
        print(f"data = {data}")
        try:
            msg = decrypt(data, shared_key, iv)
        except Exception as e:
            self.wfile.write(bytes(f"Error: {e}\n", 'utf-8'))
            return
        msg = msg.lower().strip().decode("utf-8")
        print(f"Answer: {msg}")
        answer,pirozhok0 = msg.split(" ")
        if pirozhok == pirozhok0:
            reply = "You sent me an inedible pirozhok."
        elif answer == "linux":
            reply = "correct_choice_flag_2234fcc34cf2"
        elif answer == 'windows':
            reply = "weird_choice_flag_a996f2e2f1e7"
        elif answer == 'macos':
            reply = "show_off_choice_flag_76305fb5a9b2"
        else:
            reply = "Wrong answer, try again ..."
        self.wfile.write(bytes(reply, 'utf-8'))

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} port_number")
        exit(1)

    port = int(sys.argv[1])
    
    HOST, PORT = "localhost", port

    # Create the server, binding to localhost on port 9999
    with socketserver.ThreadingTCPServer((HOST, PORT), MyTCPHandler) as server:
        # Activate the server; this will keep running until you
        # interrupt the program with Ctrl-C
        server.serve_forever()