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

  static const Map<String, int> _vocals = {
    // Extremely close / equal clusters grouped at the top
    'aɪ': 0, 'ai': 0, 'ɑɪ': 0,                 // closing front diphthong, very close
    'aʊ': 1, 'au': 1,                          // closing back diphthong, equal
    'ɑ': 2, 'ɑː': 2, 'ɔ': 2, 'ɔː': 2,          // very close back vowels
    'eɪ': 3, 'ei': 3,                          // closing front diphthong, equal
    'eə': 4, 'eu': 4,                          // centering diphthong, equal
    'i': 5, 'iː': 5, 'ɪ': 5,                   // very close
    'ie': 6, 'ɪə': 6,                          // centering diphthong, equal
    'ɜ': 7, 'ɜː': 7,                           // open-mid central, very close
    'ə': 8, 'ɚ': 8, 'ɝ': 8,                    // rhotic / unstressed central, very close
    'iu': 9, 'ui': 9, 'ʊə': 9, 'uo': 9,        // centering diphthong, very close
    'oa': 10, 'oʊ': 10, 'ou': 10, 'əʊ': 10,    // closing back diphthong, very close
    'œ': 11, 'ø': 11,                          // front rounded, very close
    'oi': 12, 'ɔɪ': 12,                        // equal
    'u': 13, 'uː': 13,                         // very close

    // Vowel monophthongs + rhotic + central (not already grouped)
    'a': 20, 'ã': 21, 'æ': 22, 'e': 23, 'ɛ': 24, 'ɐ': 25, 'ɒ': 26,
    'o': 27, 'õ': 28, 'ʌ': 29, 'ɘ': 30, 'ɵ': 31, 'ɨ': 32, 'ʉ': 33,
    'y': 34, 'ʊ': 35,

    // Diphthongs (rest not already grouped)
    'ea': 36, 'eo': 37, 'ia': 38, 'io': 39, 'ua': 40, 'ɔu': 41,

    // Triphthongs
    'aɪə': 42, 'aʊə': 43, 'eɪə': 44, 'iau': 45, 'iao': 46, 'iou': 47,
    'oʊə': 48, 'ɔɪə': 49, 'uai': 50
  };

  static const Map<String, int> _consonants = {
    // Pulmonic consonants, start at 60
    'ɓ': 60, 'b': 60, 'c': 61, 'ɗ': 62, 'd': 62, 'ð': 63, 'ɖ': 64,
    'ɸ': 65, 'f': 65, 'ɠ': 66, 'ɡ': 66, 'ʛ': 67, 'ɢ': 67,
    'ɦ': 68, 'h': 68, 'ħ': 69, 'ɟ': 70, 'ʄ': 70, 'j': 70,
    'k': 71, 'ɫ': 72, 'ɭ': 72, 'ʎ': 72, 'ɺ': 72, 'l': 72,
    'ɱ': 73, 'm': 73, 'ɳ': 74, 'ɲ': 74, 'ŋ': 74, 'ɴ': 74, 'n': 74,
    'p': 75, 'q': 76, 'ɾ': 77, 'ɹ': 77, 'ɻ': 77, 'r': 77,
    's': 78, 'ʂ': 79, 'ɕ': 79, 'ʃ': 79, 'θ': 80, 'ʈ': 81, 't': 81,
    'ʧ': 82, 'ʦ': 82, 'ʋ': 83, 'v': 83, 'ʍ': 84, 'w': 84,
    'χ': 85, 'ɣ': 85, 'ʁ': 85, 'x': 85,
    'z': 86, 'ʐ': 87, 'ʑ': 87, 'ʒ': 87, 'ʔ': 88,
  };

  static const Map<String, int> _other = {
    'ˈ': 160,  // primary stress
    'ˌ': 161,  // secondary stress
    '.': 162,  // syllable break
    ' ': 163,  // space break
  };

  static const spaceKey =  163;

  static const Map<String, int> _phonemes = {
    ..._vocals,
    ..._consonants,
    ..._other,
  };

  static final Set<int> _vowelKeys = _vocals.values.toSet();
  static final Set<int> _consonantKeys = _consonants.values.toSet();

  static final Map<int, String> _phonemeKeyMap
  = _phonemes.map((k, v) => MapEntry(v, k));

  /// Checks if a single key code represents a consonant
  static bool isKeyConsonant(int key) => _consonantKeys.contains(key);

  /// Checks if a single key code represents a vowel
  static bool isKeyVocal(int key) =>  _vowelKeys.contains(key);

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

        final code = _phonemes[substr];
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
  static String toIpa(Uint8List key) {
    final buffer = StringBuffer();
    for (var code in key) {
      final cluster = _phonemeKeyMap[code];
      if (cluster != null) buffer.write(cluster);
    }
    return buffer.toString();
  }

  /// Extracts only vowels from a byte key
  static Uint8List keyVocals(Uint8List key) =>
      Uint8List.fromList(key.where((byte) => isKeyVocal(byte)).toList());

  /// Extracts only consonants from a byte key
  static Uint8List keyConsonants(Uint8List key) =>
      Uint8List.fromList(key.where((byte) => isKeyConsonant(byte)).toList());

  /// Extracts only vowels from a byte key
  static int keySyllables(Uint8List key) => keyVocals(key).length;

  /// Returns all subkeys starting at each position of the key
  static List<Uint8List> subKeys(Uint8List input) =>
      List.generate(input.length, (i) => input.sublist(i));

  static String trim(String ipa) {
    if(ipa.length > 2) {
        return ipa.substring(1, ipa.length - 1);
    }
    return ipa;
  }

  static String keyedIpa(String ipa) => toIpa(toKey(trim(ipa)));

  static bool keyEquals(Uint8List key1, Uint8List key2) {
    if (identical(key1, key2)) return true; // same reference
    if (key1.lengthInBytes != key2.lengthInBytes) return false;

    for (var i = 0; i < key1.lengthInBytes; i++) {
      if (key1[i] != key2[i]) return false;
    }
    return true;
  }

  static String keyCode(Iterable<int> key) => String.fromCharCodes(key);

  /// Extracts the last consonant cluster from a byte key
  static Uint8List lastConsonantCluster(Uint8List key) {
    int end = key.length - 1;
    while (end >= 0 && isKeyConsonant(key[end])) { end--; }
    return Uint8List.fromList(key.sublist(end + 1));
  }

  /// Extracts the last consonant cluster from a byte key
  static int lastVocal(Uint8List key) =>
      key.lastWhere(isKeyVocal, orElse: () => 0);

  static bool isKeyPhrase(Uint8List key) => key.contains(spaceKey);

  /// Extracts the last consonant cluster from a byte key
  static Uint8List phraseConsonantClusters(Uint8List key) {
    final List<Uint8List> tokens = splitKey(key);
    final List<int> clusters = [];
    if(tokens.length < 2) return Uint8List.fromList(clusters);
    clusters.addAll(IPA.lastConsonantCluster(tokens.first));
    clusters.addAll(IPA.lastConsonantCluster(tokens.last));
    return Uint8List.fromList(clusters);
  }

  static List<Uint8List> splitKey
      (Uint8List data, {int delimiter = spaceKey}) {
    var chunks = <Uint8List>[];
    for (var start = 0, i = 0; i <= data.length; i++) {
      if (i == data.length || data[i] == delimiter) {
        chunks.add(data.sublist(start, i));
        start = i + 1;
      }
    }
    return chunks;
  }
}
