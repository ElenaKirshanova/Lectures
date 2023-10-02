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
    try
    {
    HMAC< SHA256 > hmac(key, key.size());
    const int flags = HashVerificationFilter::THROW_EXCEPTION | HashVerificationFilter::HASH_AT_END;

    StringSource(plaintext + tag, true,
        new HashVerificationFilter(hmac, NULL, flags)
    ); // StringSource

    return 1;
    }
    catch(const CryptoPP::Exception& e)
    {
        std::cerr << e.what() << std::endl;
        return 0;
    }
}

int main()
{
    random_shuffle(std::begin(plaintexts), std::end(plaintexts));
    unsigned int ctr = 0;
    for(auto i: students)
    {

        std::string plaintext = plaintexts[ctr], tag;

        SecByteBlock key(32);

        KeyGen(key);

        Sign(key, plaintext, tag);


        std::ofstream filetmp(i+".txt");

        std::string tmpstr;
        tmpstr.clear();
        StringSource(key, key.size(), true,
                     new HexEncoder(
                             new StringSink(tmpstr)
                     ) // HexEncoder
        );


        filetmp << "key: " << tmpstr << std::endl;


        tmpstr.clear();
        StringSource(tag, true,
                     new HexEncoder(
                             new StringSink(tmpstr)
                     ) // HexEncoder
        );

        filetmp << "message, tag: " << std::endl;
        filetmp << plaintext << " " << tmpstr << std::endl;

        //std::cout<< Verify(key, plaintext,tag)<< std::endl;

        std::cout<< plaintext << " " << tmpstr  << " " << Verify(key, plaintext,tag) << std::endl;

        tag[2] ^= 0x02;
        tmpstr.clear();
        StringSource(tag, true,
                     new HexEncoder(
                             new StringSink(tmpstr)
                     ) // HexEncoder
        );

        std::cout<< plaintext << " " << tmpstr  << " " << Verify(key, plaintext,tag) << std::endl;
        filetmp << plaintext << " " << tmpstr << std::endl;
        
        filetmp.close();

        ctr++;

    }
	return 0;
}
