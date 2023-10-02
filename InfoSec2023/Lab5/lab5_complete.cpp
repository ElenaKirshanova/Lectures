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
    ECDSA<ECP,SHA256>::Verifier verifier(publicKey);
    bool result = false;
    StringSource ss( signature+message, true,
                new SignatureVerificationFilter(
                verifier, new ArraySink( (byte*)&result, sizeof(result) ) ) );

    return result;
    
}
int main()
{


    random_shuffle(std::begin(plaintexts), std::end(plaintexts));

    ECDSA<ECP, SHA256>::PrivateKey privateKey;
    ECDSA<ECP, SHA256>::PublicKey publicKey;
    KeyGen(privateKey, publicKey);

    HexEncoder encoder( new FileSink( "publicKey.txt", false /*binary*/ ));
    publicKey.Save( encoder );

    unsigned int ctr = 0;
    for(auto i: students)
    {
        std::string signature, tmpstr, filename;

        std::ofstream filetmp(i+".txt");
        std::ofstream filetmp2(i+"_solutions.txt");

        bool randbit=rand()%2;
        std::cout << int(randbit) << std::endl;



        //std::cout << std::hex << publicKey.GetPublicElement().x << std::endl;
        //std::cout << std::hex << publicKey.GetPublicElement().y << std::endl;

        //CryptoPP::Integer pubkeyX = publicKey.GetPublicElement().x;
        //CryptoPP::Integer pubkeyY = publicKey.GetPublicElement().y;

        
        filetmp << "message: " << plaintexts[ctr] << std::endl;
        filetmp2 << "message: " << plaintexts[ctr] << std::endl;

        Sign(privateKey, plaintexts[ctr], signature);

        tmpstr.clear();
        StringSource(signature, true,
                         new HexEncoder(
                                 new StringSink(tmpstr))
            );
        //std::cout << tmpstr << std::endl;

        std::string signature_scrambled = tmpstr;
        signature_scrambled[0] ^= 0x02;
        signature_scrambled[9] ^= 0x09;

        if (randbit){
            filetmp << "signature : " << signature_scrambled << std::endl;
            filetmp2 << "signature : " << signature_scrambled << " verification : "<< int(Verify(publicKey, plaintexts[ctr], signature_scrambled)) << std::endl;
            filetmp << "signature : " << tmpstr << std::endl;
            filetmp2 << "signature : " << tmpstr << " verification : "<< int(Verify(publicKey, plaintexts[ctr], signature)) << std::endl;
        }
        else
        {
            filetmp << "signature : " << tmpstr << std::endl;
            filetmp2 << "signature : " << tmpstr << " verification : "<< int(Verify(publicKey, plaintexts[ctr], signature)) << std::endl;
            filetmp << "signature : " << signature_scrambled << std::endl;
            filetmp2 << "signature : " << signature_scrambled << " verification : "<< int(Verify(publicKey, plaintexts[ctr], signature_scrambled)) << std::endl;
        }
        
        filetmp.close();
        filetmp2.close();

        ctr++;
    }
     
    
	return 0;
}
