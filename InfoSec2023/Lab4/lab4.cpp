#include "cryptlib.h"
#include "sha.h"
#include "modes.h"
#include "files.h"
#include "osrng.h"
#include "hex.h"
#include "cryptopp/oids.h"

#include <iostream>
#include <string>
#include "cryptopp/eccrypto.h"
using CryptoPP::ECP;
using CryptoPP::ECDH;
using namespace CryptoPP;
#include "cryptopp/oids.h"
using CryptoPP::OID;

#include "cryptopp/asn.h"
using namespace CryptoPP::ASN1;


OID Curve = secp256r1(); //choose a secure curve
AutoSeededX917RNG<AES> rng; //pseudo-random generator

// generate Alices privete/public key pair
void AliceGen(ECDH < ECP >::Domain &dhA, SecByteBlock &privA, SecByteBlock &pubA)
{
    dhA.GenerateKeyPair(rng, privA, pubA);

}

// generate Bob's privete/public key pair
void BobGen(ECDH < ECP >::Domain &dhB, SecByteBlock &privB, SecByteBlock &pubB )
{
    //TODO
}

// Alice derives here shared key
void AliceDerive(ECDH < ECP >::Domain &dhA, SecByteBlock &privA, SecByteBlock &pubB, SecByteBlock &sharedA)
{
    const bool rtn = dhA.Agree(sharedA, privA, pubB);
    if(!rtn){ throw std::runtime_error("Failed to reach shared secret for A"); }

}

// Bob derives his shared ley
void BobDerive(ECDH < ECP >::Domain &dhB, SecByteBlock &privB, SecByteBlock &pubA, SecByteBlock &sharedB)
{
    //TODO
}


// key generation based on the shared key
void KeyGen(SecByteBlock &shared, SecByteBlock &symkey, SecByteBlock &iv)
{
    SHA256().CalculateDigest(symkey, shared, shared.size()); // hash the shared key
    rng.GenerateBlock(iv, AES::BLOCKSIZE);
}

// AES encryption in CRT mode (see Lab 2)
void Enc(SecByteBlock &key, SecByteBlock &iv, std::string &plaintext, std::string &ciphertext)
{
	try
  {
        CTR_Mode< AES >::Encryption e;
        e.SetKeyWithIV(key, key.size(), iv);

        StringSource s(plaintext, true,
            new StreamTransformationFilter(e, new StringSink(ciphertext)) // StreamTransformationFilter
        );
  }
  catch(const Exception& e)
  {
    std::cerr << "ENC ERROR: " << e.what() << std::endl;
    exit(1);
  }
}

// AES decryption in CRT mode (see Lab 2)
void Dec(SecByteBlock &key, SecByteBlock &iv, std::string &ciphertext, std::string &decrypted)
{
  // TODO
}

int main()
{

    ECDH < ECP >::Domain dhA( Curve ), dhB(Curve);

    SecByteBlock privA(dhA.PrivateKeyLength()), pubA(dhA.PublicKeyLength());
    AliceGen(dhA, privA, pubA);

    SecByteBlock privB(dhB.PrivateKeyLength()), pubB(dhB.PublicKeyLength());
    // ...
    // printing SecByteBlock data
    // std::string tmpstr;
    //    tmpstr.clear();
    //    StringSource(pubA, pubA.size(), true,
    //                 new HexEncoder(
    //                         new StringSink(tmpstr)
    //                 ) // HexEncoder
    //    );


}
