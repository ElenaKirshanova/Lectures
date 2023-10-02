#include "cryptlib.h"
#include "rijndael.h"
#include "modes.h"
#include "files.h"
#include "osrng.h"
#include "hex.h"

#include <iostream>
#include <string>
using namespace CryptoPP;

// On MAC: clang++ lab2.cpp -stdlib=libc++ -L/usr/local/lib -I//usr/local/include/cryptopp -lcryptopp

void KeyGen(SecByteBlock &key, SecByteBlock &iv)
{
	AutoSeededRandomPool prng;

	prng.GenerateBlock(key, key.size());
	prng.GenerateBlock(iv, iv.size());
}

void Enc(SecByteBlock &key, SecByteBlock &iv, std::string &plaintext, std::string &ciphertext)
{
	try
  {
        CTR_Mode< AES >::Encryption e;
        e.SetKeyWithIV(key, key.size(), iv);

        StringSource s(plaintext, true,
            new StreamTransformationFilter(e, new StringSink(ciphertext)) // StreamTransformationFilter
        ); // StringSource
  }
  catch(const Exception& e)
  {
    std::cerr << e.what() << std::endl;
    exit(1);
  }
}

void Dec(SecByteBlock &key, SecByteBlock &iv, std::string &ciphertext, std::string &decrypted)
{
	// YOUR CODE HERE
}

int main()
{
	std::string plaintext = "Encryption in counter mode", ciphertext, decrypted;

    SecByteBlock key(AES::DEFAULT_KEYLENGTH);
    SecByteBlock iv(AES::BLOCKSIZE);

	KeyGen(key, iv);

	std::cout << "Plaintext: " << plaintext << std::endl;

	Enc(key, iv, plaintext, ciphertext);

	std::cout << "Ciphertext: " << ciphertext << std::endl;

	Dec(key, iv, ciphertext, decrypted);

	std::cout << "Decrypted: " << decrypted << std::endl;

	return 0;
}
