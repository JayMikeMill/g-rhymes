import 'dart:convert';
import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'package:g_rhymes/helpers/log.dart';

import 'ipa.dart';
import 'g_dict.dart';
import 'hive_storage.dart';

part 'rhyme_dict.g.dart'; // Generated adapter file

late RhymeDict globalRhymeDict = RhymeDict(GDict());

Future<void> loadRhymeDict() async {
  Log.i('Loading Rhyming dictionary...');
  globalRhymeDict = await HiveStorage.getRhymeDict('english');
  Log.i('Finished!');
}

@HiveType(typeId: 6)
class RhymeDict extends HiveObject {

  @HiveField(0) GDict dict = GDict();

  @HiveField(1) Map<String, List<int>> sounds      = {};
  @HiveField(2) Map<String, List<int>> vocals      = {};
  @HiveField(3) Map<String, List<int>> consonants  = {};

  RhymeDict(this.dict) {
    buildRhymes();
  }

  void clear() {
    sounds.clear(); vocals.clear(); consonants.clear();
  }
  void buildRhymes() {
    clear();

    int senseIndex = 0;
    for (final sense in dict.senses) {
      List<Uint8List> sKeys = IPA.subKeys(sense.ipak);
      List<Uint8List> vKeys = IPA.subKeys(IPA.keyVocals(sense.ipak));
      List<Uint8List> cKeys = IPA.subKeys(
          IPA.keyConsonants(sense.ipak));

      for (final key in sKeys) {
        sounds.putIfAbsent(base64Encode(key), () => []).add(senseIndex);
      }
      for (final key in vKeys) {
        vocals.putIfAbsent(base64Encode(key), () => []).add(senseIndex);
      }
      for (final key in cKeys) {
        consonants.putIfAbsent(base64Encode(key), () => []).add(senseIndex);
      }

      senseIndex++;
    }
  }

  GDict getRhymes(String token, RhymeSearchProps searchProps) {
    DictEntry? entry = dict.getEntry(token);
    if(entry == null) return GDict();

    //Uint8List sKeys = IPA.keyConsonants(wordInf.ipak);
    //Uint8List cKeys = IPA.keyConsonants(wordInf.ipak);
    bool perfect = searchProps.rhymeType == RhymeType.perfect;

    List<int> rhymes = [];
    for(final sense in entry.senses) {
      Uint8List vKeys = IPA.keyVocals(sense.ipak);

      List<int> searchKey = [vKeys.last];
      if(perfect) searchKey = vKeys;

      rhymes.addAll(vocals[base64Encode(searchKey)] ?? []);

      if(perfect) {
        final matchSet = sounds[base64Encode([sense.ipak.last])]?.toSet() ?? {};
        rhymes = rhymes.where((i) => matchSet.contains(i)).toList();
      }
    }

    SpeechType st = searchProps.speechType;
    if(st != SpeechType.all) {
      rhymes.removeWhere((i) =>
      !st.wordPoS.contains(dict.getSense(i)!.pos));
    }

    return _senseIndexesToDict(rhymes);
  }

  GDict _senseIndexesToDict(List<int> indexes) {
    GDict rhymes = GDict();
    for (final index in indexes) {
        rhymes.addEntry(dict.getSenseEntry(index)!);
    }

    return rhymes;
  }
}

/// --- Properties ---
class RhymeSearchProps {
  RhymeType rhymeType   = RhymeType.perfect;
  SpeechType speechType = SpeechType.common;
  WordType wordType     = WordType.common;
  int syllables         = 0; // 0 = All
}

/// --- Enhanced enums with display names ---
enum RhymeType {
  all('All'),
  perfect('Perfect'),
  near('Near'),
  vowel('Vowel'),
  conso('Consonant');

  final String displayName;
  const RhymeType(this.displayName);
}


const Set<PartOfSpeech> commonSpeechTypes = {
  PartOfSpeech.noun, PartOfSpeech.verb, PartOfSpeech.adjective,
  PartOfSpeech.adverb, PartOfSpeech.pronoun
};

enum SpeechType {
  all('All', commonSpeechTypes),
  common('Common', commonSpeechTypes),
  noun('Nouns', {PartOfSpeech.noun}),
  verb('Verbs', {PartOfSpeech.verb}),
  adjective('Adjectives', {PartOfSpeech.adjective}),
  phrase('Phrases', {PartOfSpeech.phrase}),
  name('Names', {PartOfSpeech.name}),
  other('Other', {PartOfSpeech.other});

  final String displayName;
  final Set<PartOfSpeech> wordPoS;
  const SpeechType(this.displayName, this.wordPoS);
}

enum WordType {
  all('All'),
  common('Common'),
  uncommon('Uncommon'),
  slang('Slang'),
  vulgar('Vulgar');

  final String displayName;
  const WordType(this.displayName);
}
