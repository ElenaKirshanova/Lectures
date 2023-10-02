#include "cryptlib.h"
#include "poly1305.h"
#include "sha.h"
#include "modes.h"
#include "files.h"
#include "osrng.h"
#include "hex.h"

#include <iostream>
#include <string>
using namespace CryptoPP;

// On MAC: clang++ lab3.cpp -std=c++11 -L/usr/local/lib -I/usr/local/include/cryptopp -lcryptopp
void KeyGen(SecByteBlock &key)
{
	AutoSeededRandomPool prng;

	prng.GenerateBlock(key, key.size());
}

void Sign(SecByteBlock &key, std::string &plaintext, std::string &tag)
{
	try
  {
        HMAC< SHA256 > hmac(key, key.size());
        StringSource ss2(plaintext, true,
            new HashFilter(hmac,
                new StringSink(tag)
            )
        );
  }
  catch(const Exception& e)
  {
    std::cerr << "SIGN ERROR: " << e.what() << std::endl;
    exit(1);
  }
}

bool Verify(SecByteBlock &key,  std::string &plaintext, std::string &tag)
{
   //YOUR CODE HERE
}

int main()
{
    //TODO
	return 0;
}
