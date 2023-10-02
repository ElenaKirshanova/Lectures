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


//	std::cout << "Plaintext: " << plaintext << std::endl;

//	Enc(key, iv, plaintext, ciphertext);

//	std::cout << "Ciphertext: " << ciphertext << std::endl;

//	Dec(key, iv, ciphertext, decrypted);

//	std::cout << "Decrypted: " << decrypted << std::endl;

    unsigned int ctr = 0;
    for(auto i: students)
    {

        std::string plaintext = plaintexts[ctr], ciphertext, decrypted;

        SecByteBlock key(AES::DEFAULT_KEYLENGTH);
        SecByteBlock iv(AES::BLOCKSIZE);


        KeyGen(key, iv);

        Enc(key, iv, plaintext, ciphertext);


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
        StringSource(iv, iv.size(), true,
                     new HexEncoder(
                             new StringSink(tmpstr)
                     ) // HexEncoder
        );
        std::cout << "iv: " << tmpstr << std::endl;
        filetmp << "iv: " << tmpstr << std::endl;

        tmpstr.clear();
        StringSource(ciphertext, true,
                     new HexEncoder(
                             new StringSink(tmpstr)
                     ) // HexEncoder
        );

        filetmp << "ciphertext: " << tmpstr << std::endl;

        filetmp.close();

        ctr++;

    }

	return 0;
}
