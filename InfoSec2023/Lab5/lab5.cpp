#include "cryptlib.h"
#include "sha.h"
#include "osrng.h"
#include "hex.h"
#include "files.h"

#include <iostream>
#include <fstream>
#include <string>
#include "eccrypto.h"
using CryptoPP::ECP;
using CryptoPP::ECDH;
using namespace CryptoPP;
#include "oids.h"
using CryptoPP::OID;

#include "asn.h"
using namespace CryptoPP::ASN1;


OID Curve = secp256r1();
AutoSeededX917RNG<AES> prng;

void KeyGen(ECDSA<ECP, SHA256>::PrivateKey &privateKey, ECDSA<ECP, SHA256>::PublicKey &publicKey)
{
    privateKey.Initialize( prng, Curve );
    privateKey.MakePublicKey( publicKey );

}

void Sign(ECDSA<ECP, SHA256>::PrivateKey &privateKey, const std::string &message, std::string &signature)
{
    ECDSA<ECP,SHA256>::Signer signer( privateKey );
    StringSource s( message, true,
                    new SignerFilter( prng,
                    signer, new StringSink( signature ) )
);

}

bool Verify(ECDSA<ECP, SHA256>::PublicKey &publicKey, const std::string &message, const std::string &signature)
{
    //YOUR CODE HERE
    
}
int main()
{


    //Read-in public key
    //Read-in message+signature
    //Verify the given signatures
	return 0;
}
