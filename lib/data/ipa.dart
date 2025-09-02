/*
 * Copyright (c) 2025 GWorks
 *
 * Licensed under the GWorks Non-Commercial License.
 * You may view, copy, and modify the source code.
 * You may redistribute the source code under the same terms.
 * You may build and use the code for personal or educational purposes.
 * You may NOT sell or redistribute the built binaries.
 *
 * For the full license text, see LICENSE file in this repository.
 *
 * File: ipa.dart
 * Description: Provides utilities to encode/decode IPA strings into byte keys,
 *              classify clusters as vowels or consonants, and handle IPA
 *              transcription for multiple languages. Supports extraction of
 *              vowels/consonants and generation of subkeys for analysis.
 */

import 'dart:typed_data';
import 'package:g_rhymes/helpers/log.dart';

// -----------------------------------------------------------------------------
// Class: IPA
// Description: Provides utilities to encode/decode IPA strings into byte keys,
//              classify clusters as vowels or consonants, and handle IPA
//              transcription for multiple languages.
// -----------------------------------------------------------------------------
class IPA {
  // ---------------------------------------------------------------------------
  // Master IPA Cluster Map
  // Description: Maps IPA symbols and clusters to numeric codes (1 byte each).
  // Only includes symbols from the top 15 languages (English, Spanish, French,
  // Portuguese, German, Russian, Arabic, Hindi/Urdu, Japanese, Italian, Korean,
  // Turkish, Polish, Mandarin, Bengali). Suprasegmentals are mapped to 255.
  // ---------------------------------------------------------------------------
  static final Map<String, int> clusterMap = {
    // Vowel monophthongs + rhotic
    'i': 0, 'iː': 1, 'ɪ': 2, 'e': 3, 'ɛ': 4, 'æ': 5, 'a': 6, 'ɑ': 7, 'ɑː': 8,
    'ɒ': 9, 'o': 10, 'ɔ': 11, 'ɔː': 12, 'u': 13, 'ʊ': 14, 'uː': 15, 'ə': 16,
    'ʌ': 17, 'ɝ': 18, 'ɚ': 19, 'y': 20, 'ø': 21, 'œ': 22, 'ɜ': 23, 'ɜː': 24,
    'ɨ': 25, 'ɐ': 26, 'ʉ': 27, 'ɵ': 28, 'ɘ': 29, 'ã': 30, 'õ': 31,

    // Diphthongs
    'eɪ': 32, 'aɪ': 33, 'ɔɪ': 34, 'oʊ': 35, 'əʊ': 36, 'aʊ': 37,
    'ɪə': 38, 'eə': 39, 'ʊə': 40, 'ai': 41, 'ei': 42, 'oi': 43, 'au': 44,
    'eu': 45, 'ou': 46, 'ie': 47, 'uo': 48, 'ui': 49, 'iu': 50, 'oa': 51,
    'ja': 52, 'ju': 53, 'wa': 54, 'wo': 55, 'ɔu': 56, 'ɑɪ': 57,

    // Triphthongs
    'eɪə': 58, 'aɪə': 59, 'ɔɪə': 60, 'iau': 61, 'uai': 62, 'iao': 63, 'iou': 64,
    'aʊə': 65, 'oʊə': 66,

    // Pulmonic consonants
    'p': 67, 'b': 68, 't': 69, 'd': 70, 'ʈ': 71, 'ɖ': 72,
    'k': 73, 'ɡ': 74, 'q': 75, 'ʔ': 76,
    'm': 77, 'n': 78, 'ɲ': 79, 'ŋ': 80,
    'f': 81, 'v': 82, 'θ': 83, 'ð': 84, 's': 85, 'z': 86,
    'ʃ': 87, 'ʒ': 88, 'x': 89, 'ɣ': 90, 'h': 91, 'ɦ': 92,
    'j': 93, 'w': 94, 'ɹ': 95, 'ɻ': 96,
    'l': 97, 'ʎ': 98, 'r': 99, 'ɫ': 100, 'ɾ': 101, 'ʍ': 102, 'χ': 103,

    // Onset consonant clusters
    'pr': 104, 'pl': 105, 'br': 106, 'bl': 107, 'tr': 108, 'dr': 109,
    'kr': 110, 'kl': 111, 'gr': 112, 'gl': 113, 'fr': 114, 'fl': 115,
    'sp': 116, 'st': 117, 'sk': 118, 'sm': 119, 'sn': 120, 'sw': 121,
    'spl': 122, 'spr': 123, 'str': 124, 'skr': 125,
    'θr': 126, 'ʃr': 127, 'tw': 128, 'dw': 129,
    'ʈr': 130, 'ɖr': 131, 'ʃt': 132, 'ʒr': 133, 'ʃk': 134, 'ʃp': 135,
    'ʧr': 136, 'dʒr': 137, 'ts': 138, 'dz': 139, 'tɕ': 140, 'dʑ': 141,
    'tɬ': 142, 'dɮ': 143,
    'kw': 144, 'gw': 145, 'θw': 146,

    // Coda consonant clusters
    'nd': 147, 'nds': 148, 'nt': 149, 'nts': 150, 'ns': 151, 'nz': 152,
    'ld': 153, 'lds': 154, 'lk': 155, 'lks': 156, 'lp': 157, 'lps': 158,
    'lf': 159, 'lfs': 160, 'lm': 161, 'lms': 162, 'rd': 163, 'rds': 164,
    'rk': 165, 'rks': 166, 'rt': 167, 'rts': 168, 'rn': 169, 'rm': 170,
    'mp': 171, 'mps': 172, 'mb': 173, 'mbs': 174, 'ŋk': 175, 'ŋks': 176,
    'ŋg': 177, 'ŋgs': 178, 'st̚': 179, 'sts': 180, 'sp̚': 181, 'sps': 182,
    'sk̚': 183, 'sks': 184, 'ks': 185, 'gz': 186, 'dʒ': 187, 'tʃ': 188,
    'θs': 189, 'ɲs': 190, 'ŋs': 191,
    'lv': 192, 'ntr': 193,

    'ˈ': 194,  // primary stress
    'ˌ': 195,  // secondary stress
    '.': 196,  // syllable break

    // Suprasegmentals / modifiers (all mapped to 255)
    'ː': 255, '͡': 255, '(': 255, ')': 255,
    '̯': 255, '̩': 255, 'ʴ': 255, '̠': 255, '̃': 255, '˨': 255, '˩': 255, '̚': 255,
    ' ': 255, '/': 255, '[': 255, 'ʰ': 255, '̥': 255, '˭': 255, '̪': 255,
    '˧': 255, '̈': 255, 'ᵊ': 255, '-': 255, '˦': 255, 'c': 255,
    'ǁ': 255, '‿': 255, 'ʱ': 255, 'ʙ': 255, 'ʁ': 255, 'ç': 255, '͜': 255,
    '˞': 255, 'ˑ': 255, '|': 255, '̆': 255, 'ɶ': 255, 'ɳ': 255, 'ʷ': 255,
    'ɭ': 255, '̰': 255, 'ǀ': 255, 'ʲ': 255, '~': 255, 'ˤ': 255, '̙': 255,
    '̝': 255, 'ɬ': 255, '˥': 255, 'ä': 255, 'ɸ': 255, 'ā': 255, 'ɽ': 255,
    'ĭ': 255, 'ĩ': 255, 'ʼ': 255, 'ă': 255, 'ŏ': 255, 'ɱ': 255, 'ǐ': 255,
    'ʋ': 255, '̞': 255, 'ɟ': 255, 'ʏ': 255, '⁻': 255, '³': 255, '͆': 255,
    'ɤ': 255, '̂': 255, '̊': 255, 'β': 255, 'ˀ': 255, '¹': 255, '²': 255,
    '⁴': 255, 'ˠ': 255, 'ü': 255, 'ɯ': 255, 'ɕ': 255, 'ʳ': 255,
  };

  /// Checks if a single key code represents a consonant
  static bool isKeyConsonant(int key) => key >= 67 && key <= 188;

  /// Checks if a single key code represents a vowel
  static bool isKeyVowel(int key) =>  key >= 0 && key <= 66;

  /// Maximum cluster length to attempt when encoding IPA
  static const maxClusterLength = 3;

  // ---------------------------------------------------------------------------
  // Conversion Methods
  // ---------------------------------------------------------------------------

  /// Converts an IPA string to a byte array key
  /// Each cluster is converted to a 1-byte integer code
  static Uint8List toKey(String ipa) {
    final key = <int>[];
    int index = 0;

    while (index < ipa.length) {
      bool matched = false;

      for (int len = maxClusterLength; len > 0; len--) {
        if (index + len > ipa.length) continue;
        final substr = ipa.substring(index, index + len);

        final code = clusterMap[substr];
        if (code != null && code < 255) {
          key.add(code & 0xFF);
          index += len;
          matched = true;
          break;
        }
      }

      if (!matched) {
        //Log.w('Unknown IPA cluster at position $index: ${ipa[index]}');
        index++;
      }
    }

    return Uint8List.fromList(key);
  }

  /// Converts a byte key back into an IPA string
  static final Map<int, String> reverseMap = clusterMap.map((k, v) => MapEntry(v, k));
  static String fromKey(Uint8List key) {
    final buffer = StringBuffer();
    for (var code in key) {
      final cluster = reverseMap[code];
      if (cluster != null) buffer.write(cluster);
    }
    return buffer.toString();
  }

  /// Extracts only vowels from a byte key
  static Uint8List keyVocals(Uint8List key) =>
      Uint8List.fromList(key.where((byte) => isKeyVowel(byte)).toList());

  /// Extracts only consonants from a byte key
  static Uint8List keyConsonants(Uint8List key) =>
      Uint8List.fromList(key.where((byte) => isKeyConsonant(byte)).toList());

  /// Returns all subkeys starting at each position of the key
  static List<Uint8List> subKeys(Uint8List input) =>
      List.generate(input.length, (i) => input.sublist(i));

  static String trim(String ipa) {
    if(ipa.length > 2) {
        return ipa.substring(1, ipa.length - 1);
    }
    return ipa;
  }

  static String keyedIpa(String ipa) => fromKey(toKey(trim(ipa)));
}
