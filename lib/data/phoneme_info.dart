class PhonemeInfo {
  // Full IPA vowel set (mono-, long, di-, triphthongs)
  static const Set<String> ipaVocals = {
    'i','y','ɨ','ʉ','ɯ','u','ɪ','ʏ','ʊ','e','ø','ɘ','ɵ',
    'ɤ','o','ə','ɛ','œ','ɜ','ɞ','ʌ','ɔ','æ','ɐ','a','ɶ','ɑ','ɒ',
    'iː','uː','ɑː','ɔː','ɜː','eː','oː','æː','ɒː',
    'eɪ','aɪ','ɔɪ','aʊ','oʊ','ɪə','eə','ʊə','ɜːə','iə','uə','ɑɪ','ɑʊ','ɔːɪ',
    'æə','ɛə','ɪɪ','iːi','ɑːi','ɔːi','aɪə','aʊə','ɔɪə','eɪə','oʊə','æəʊ',
    'iːə','uːə','ɑːə','ɔːə','aɪə̯','oʊə̯'
  };

  /// All phonemes (vowel or consonant clusters)
  List<String> phonemes = [];

  /// Vowel clusters only
  List<String> vocals = [];

  /// Consonant clusters only
  List<String> frictives = [];

  /// Constructor: takes an IPA string
  PhonemeInfo(String ipa) {
    _processParts(ipa);
  }

  void _processParts(String ipa) {
    ipa = ipa.replaceAll(RegExp(r'[ˈˌ]'), ''); // remove stress markers
    int i = 0;

    while (i < ipa.length) {
      bool matched = false;

      // 1) Try vowel clusters (3 → 2 → 1 chars)
      for (int len = 3; len >= 1; len--) {
        if (i + len > ipa.length) continue;
        final chunk = ipa.substring(i, i + len);
        if (ipaVocals.contains(chunk)) {
          phonemes.add(chunk);
          vocals.add(chunk);
          i += len;
          matched = true;
          break;
        }
      }
      if (matched) continue;

      // 2) Collect consecutive non-vowels as one frictive cluster
      int start = i;
      while (i < ipa.length) {
        bool isVowelAhead = false;
        for (int len = 3; len >= 1; len--) {
          if (i + len > ipa.length) continue;
          final chunk = ipa.substring(i, i + len);
          if (ipaVocals.contains(chunk)) {
            isVowelAhead = true;
            break;
          }
        }
        if (isVowelAhead) break;
        i++;
      }
      if (i > start) {
        final cluster = ipa.substring(start, i);
        phonemes.add(cluster);
        frictives.add(cluster);
      }
    }
  }

  String getPhonemes() => phonemes.join();
  String getVocals() => vocals.join();
  String getFrictives() => frictives.join();

  List<String> lastVocalsSequences() {
    final result = <String>[];

    for (int count = 1; count <= vocals.length; count++) {
      final seq = vocals.sublist(vocals.length - count).join();
      result.add(seq);
    }

    return result;
  }
}
