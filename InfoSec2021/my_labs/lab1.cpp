//
//  lab1.cpp
//  
//
//  Created by Elena on 18/01/2021.
//

#include "lab1.hpp"

#include "cryptlib.h"
#include "secblock.h"
#include "chacha.h"
#include "osrng.h"
#include "files.h"
#include "hex.h"

#include <iostream>
#include <string>

using namespace CryptoPP;


void KeyGen(SecByteBlock &key, SecByteBlock &iv)
{
	AutoSeededRandomPool prng;
	prng.GenerateBlock(key, key.size());
	prng.GenerateBlock(iv, iv.size());
}

void Enc(SecByteBlock &key, SecByteBlock &iv, std::string &plaintext, std::string &ciphertext)
{
	// Encryption object
	ChaCha::Encryption enc;
	enc.SetKeyWithIV(key, key.size(), iv, iv.size());
	
	// Perform the encryption
	ciphertext.resize(plaintext.size());
	enc.ProcessData((byte*)&ciphertext[0], (const byte*)plaintext.data(), plaintext.size());
}

void Dec(SecByteBlock &key, SecByteBlock &iv, std::string &ciphertext, std::string &decrypted)
{
	// Decryption object
	ChaCha::Decryption dec;
	dec.SetKeyWithIV(key, key.size(), iv, iv.size());
	
	// Perform the decryption
	decrypted.resize(ciphertext.size());
	dec.ProcessData((byte*)&decrypted[0], (const byte*)ciphertext.data(), ciphertext.size());
}

int main()
{
	std::string plaintext = "some plaintext", ciphertext, decrypted;
	
	SecByteBlock key(32), iv(8);
	KeyGen(key, iv);
	
	std::cout << "Plaintext: " << plaintext << std::endl;
	
	Enc(key, iv, plaintext, ciphertext);
	
	std::cout << "Ciphertext: " << ciphertext << std::endl;
	
	Dec(key, iv, ciphertext, decrypted);
	
	std::cout << "Decrypted: " << decrypted << std::endl;
	
	return 0;
}
