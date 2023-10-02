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

// On MAC: clang++ lab3.cpp -stdlib=libc++ -L/usr/local/lib -I/usr/local/include/cryptopp -lcryptopp
// On MAC: clang++ lab3.cpp -std=c++11 -L/usr/local/lib -I/usr/local/include/cryptopp -lcryptopp
std::string students[]
      = { "Aleschenkov", "Andreichenko", "Arsent'ev", "Bocharnikov", "Gorbovsky", "Gross", "Diky", "Dudorova",
          "Egurnov", "Ismailov", "Kalyugin", "Karaichev", "Mazinova", "Marphin", "Nagernyuk", "Orlov", "Panov",
          "Rakhimberdin", "Rodin", "Rydix", "Sukhomlin", "Khromova", "Chuprun", "Shukaev", "Shushin", "Zozulin",
          "Milyutina", "Obrekht", "Pekisheva", "Racheva"};


std::string plaintexts[]
        = {
        "Knowledge comes, but wisdom lingers.",
        "Where there is a monster, there is a miracle.",
        "It is only with the heart that one can see rightly; what is essential is invisible to the eye.",
        "And, now that you don’t have to be perfect you can be good.",
        "Even the darkest night will end and the sun will rise.",
        "It’s the possibility of having a dream come true that makes life interesting.",
        "So many things are possible just as long as you don’t know they’re impossible.",
        "Science is what you know. Philosophy is what you don't know.",
        "The farther backward you can look, the farther forward you are likely to see.",
        "The price of greatness is responsibility.",
        "Strength does not come from physical capacity. It comes from an indomitable will.",
        "There is no sin except stupidity.",
        "Questions are never indiscreet, answers sometimes are.",
        "Beware; for I am fearless, and therefore powerful.",
        "The cure for boredom is curiosity. There is no cure for curiosity.",
        "Knowledge makes a man unfit to be a slave.",
        "Who controls the past controls the future. Who controls the present controls the past.",
        "It does not do to dwell on dreams and forget to live.",
        "I had the epiphany that laughter was light, and light was laughter, and that this was the secret of the universe",
        "Anyone who ever gave you confidence, you owe them a lot.",
        "Isn’t it nice to think that tomorrow is a new day with no mistakes in it yet?",
        "Memories, even your most precious ones, fade surprisingly quickly. But I don’t go along with that. The memories I value most, I don’t ever see them fading.",
        "Nowadays people know the price of everything and the value of nothing.",
        "The voice of the sea is seductive, never ceasing, whispering, clamoring, murmuring, inviting the soul to wander in abysses of solitude.",
        "It doesn’t matter who you are or what you look like, so long as somebody loves you.",
        "Brave doesn’t mean you’re not scared. It means you go on even though you’re scared.",
        "And, when you want something, all the universe conspires in helping you to achieve it.”",
        "There is always something left to love.",
        "Time moves slowly, but passes quickly.",
        "It is our choices, Harry, that show what we truly are, far more than our abilities."
};

OID Curve = secp256r1();
AutoSeededX917RNG<AES> rng;

void AliceGen(ECDH < ECP >::Domain &dhA, SecByteBlock &privA, SecByteBlock &pubA)
{
    dhA.GenerateKeyPair(rng, privA, pubA);

}

void BobGen(ECDH < ECP >::Domain &dhB, SecByteBlock &privB, SecByteBlock &pubB )
{
    dhB.GenerateKeyPair(rng, privB, pubB);
}

void AliceDerive(ECDH < ECP >::Domain &dhA, SecByteBlock &privA, SecByteBlock &pubB, SecByteBlock &sharedA)
{
    const bool rtn = dhA.Agree(sharedA, privA, pubB);
    if(!rtn){ throw std::runtime_error("Failed to reach shared secret for A"); }

}

void BobDerive(ECDH < ECP >::Domain &dhB, SecByteBlock &privB, SecByteBlock &pubA, SecByteBlock &sharedB)
{
    const bool rtn = dhB.Agree(sharedB, privB, pubA);
    if(!rtn){ throw std::runtime_error("Failed to reach shared secret for B"); }
}

void KeyGen(SecByteBlock &shared, SecByteBlock &symkey, SecByteBlock &iv)
{
    SHA256().CalculateDigest(symkey, shared, shared.size());
    rng.GenerateBlock(iv, AES::BLOCKSIZE);
}

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

void Dec(SecByteBlock &key, SecByteBlock &iv, std::string &ciphertext, std::string &decrypted)
{
  try
  {
        CTR_Mode< AES >::Decryption d;
        d.SetKeyWithIV(key, key.size(), iv);

        StringSource s(ciphertext, true, new StreamTransformationFilter(d, new StringSink(decrypted)) // StreamTransformationFilter
        ); // StringSource
    }
    catch(const Exception& e)
    {
        std::cerr << e.what() << std::endl;
        exit(1);
    }
}

int main()
{
    random_shuffle(std::begin(plaintexts), std::end(plaintexts));
    ECDH < ECP >::Domain dhA( Curve ), dhB(Curve);

    unsigned int ctr = 0;
    for(auto i: students)
    {
        std::ofstream filetmp(i+".txt");
        std::ofstream filetmp2(i+"_solutions.txt");
        SecByteBlock privA(dhA.PrivateKeyLength()), pubA(dhA.PublicKeyLength());
        AliceGen(dhA, privA, pubA);

        std::string tmpstr;
        tmpstr.clear();
        StringSource(pubA, pubA.size(), true,
                     new HexEncoder(
                             new StringSink(tmpstr)
                     ) // HexEncoder
        );

        filetmp<< "Alice's pk: " << tmpstr << std::endl;
        filetmp2<< "Alice's pk: " << tmpstr << std::endl;

        SecByteBlock privB(dhB.PrivateKeyLength()), pubB(dhB.PublicKeyLength());
        BobGen(dhB, privB, pubB);

        tmpstr.clear();
        StringSource(privB, privB.size(), true,
                     new HexEncoder(
                             new StringSink(tmpstr)
                     ) // HexEncoder
        );
        filetmp<< "Bob's sk: " << tmpstr << std::endl;
        filetmp2<< "Bob's sk: " << tmpstr << std::endl;

        SecByteBlock sharedA (dhA.AgreedValueLength());
        SecByteBlock sharedB (dhB.AgreedValueLength());

        AliceDerive(dhA, privA, pubB, sharedA);
        BobDerive(dhB, privB, pubA, sharedB);

        tmpstr.clear();
        StringSource(sharedA, sharedA.size(), true,
                     new HexEncoder(
                             new StringSink(tmpstr)
                     ) // HexEncoder
        );

        filetmp2<< "Shared key: " << tmpstr << std::endl;

        Integer a, b;
        a.Decode(sharedA.BytePtr(), sharedA.SizeInBytes());
        b.Decode(sharedB.BytePtr(), sharedB.SizeInBytes());
        const bool check = a == b;
        if(!check)
        throw std::runtime_error("Failed to reach shared secret");

        SecByteBlock key(SHA256::DIGESTSIZE);

        SecByteBlock iv(AES::BLOCKSIZE);
        SecByteBlock iv2(AES::BLOCKSIZE);

        SecByteBlock key2(SHA256::DIGESTSIZE);

        KeyGen(sharedA, key, iv);
        KeyGen(sharedB, key2, iv2);

        tmpstr.clear();
        StringSource(iv, iv.size(), true,
                     new HexEncoder(
                             new StringSink(tmpstr)
                     ) // HexEncoder
        );
        filetmp<< "iv: " << tmpstr << std::endl;
        filetmp2<< "iv: " << tmpstr << std::endl;


        std::string ciphertext, decrypted;
        Enc(key, iv, plaintexts[ctr], ciphertext);
        Dec(key2, iv, ciphertext, decrypted);

        tmpstr.clear();
        StringSource(ciphertext, true,
                     new HexEncoder(
                             new StringSink(tmpstr)
                     ) // HexEncoder
        );

        filetmp<< "ciphertext: " << tmpstr << std::endl;

        filetmp2 << " plaintext " << plaintexts[ctr] << std::endl;
        filetmp2 <<" ciphertext " << tmpstr << std::endl;

        tmpstr.clear();
        StringSource(decrypted, true,
                     new HexEncoder(
                             new StringSink(tmpstr)
                     ) // HexEncoder
        );

        filetmp2 <<" decrypted " << decrypted << std::endl;

        filetmp.close();
        filetmp2.close();
        ctr++;
    }
    
	return 0;
}
