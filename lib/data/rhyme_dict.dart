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
 * File: rhyme_dict.dart
 * Description: Stores a GDict dictionary and precomputes rhymes for quick lookup.
 *              Provides rhyme searching based on vowels, consonants, and perfect rhymes.
 */
import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'ipa.dart';
import 'g_dict.dart';

part 'rhyme_dict.g.dart'; // Hive-generated adapter file

// -----------------------------------------------------------------------------
// Class: RhymeDict
// Description: Stores a dictionary and precomputes rhymes for quick lookup
// -----------------------------------------------------------------------------

@HiveType(typeId: 7)
class RhymeDict extends HiveObject {
  @HiveField(0)
  GDict dict = GDict();

  static const  vocAll = 0, vocEnds = 1, consLast = 2;

  @HiveField(1)
  Map<int, Map<String, Uint8List>> rhymes = {};

  RhymeDict();

  RhymeDict.buildFrom(GDict fromDict) {
    build(fromDict);
  }

  /// Build rhymes from dictionary, fast and safe
  void build(GDict fromDict) {
    dict = fromDict;

    // Temporary storage as List<int> for fast append
    Map<int, Map<String, List<int>>> temp =
    { vocAll: {}, vocEnds: {}, consLast: {} };

    for (int i = 0; i < dict.senses.length; i++) {
      final ipak = dict.senses[i].ipak;
      final vocals = IPA.keyVocals(ipak);
      final bool isPhrase = IPA.isKeyPhrase(ipak);

      // add all vocals key
      temp[vocAll]!.putIfAbsent(IPA.keyCode(vocals), () => []).add(i);

      // Add vocal ends key
      final Uint8List vocEndKey = isPhrase ?
      IPA.phraseLastVocals(ipak) :
      IPA.endVocals(ipak);
      if (vocEndKey.isNotEmpty) {
        temp[vocEnds]!.putIfAbsent(IPA.keyCode(vocEndKey), () => []).add(i);
      }

      // Add last consonant cluster
      final Uint8List ccKey = isPhrase ?
      IPA.phraseConsonantClusters(ipak) :
      IPA.lastConsonantCluster(ipak);
      if (ccKey.isNotEmpty) {
        temp[consLast]!.putIfAbsent(IPA.keyCode(ccKey), () => []).add(i);
      }
    }

    // Map List<int>s to Uint32List->Uint8List
    for(final list in temp.entries) {
      rhymes[list.key] = temp[list.key]!.map((k, v) =>
          MapEntry(k, Uint32List.fromList(v).buffer.asUint8List()));
    }
  }

  /// Retrieve rhymes for a query and search params
  GDict getRhymes(RhymeSearchParams params) {
    String token = params.query;
    final entry = dict.getEntry(token);

    if (entry == null) return tryPhrase(token, params);

    final resultIndices = <int>[];

    for (final sense in entry.senses) {
      resultIndices.addAll(getRhymeList(sense.ipak, params));
    }

    // Apply syllable, type, and speech filters
    final filteredIndices = _filterIndexes(resultIndices, params);

    return _senseIndexesToDict(filteredIndices);
  }

  GDict tryPhrase(String token, RhymeSearchParams params) {
    if (!token.contains(' ')) return GDict();

    String phraseIpa = dict.getPhraseIpa(token);
    Uint8List phraseKey = IPA.toKey(phraseIpa);

    final resultIndices = getRhymeList(phraseKey, params);

    // Apply syllable, type, and speech filters
    final filteredIndices = _filterIndexes(resultIndices, params);

    return _senseIndexesToDict(filteredIndices);
  }

  /// Get list of sense indices for a given key
  List<int> getRhymeList(Uint8List ipak, RhymeSearchParams params) {
    final perfect = params.rhymeType == RhymeType.perfect;

    // phrase rhymes and regualar rhymes
    if(IPA.isKeyPhrase(ipak)) {
      final vocKey = IPA.phraseLastVocals(ipak);
      final ccKey  = IPA.phraseConsonantClusters(ipak);
      final list   = getRhymeIndices(vocEnds, IPA.keyCode(vocKey));

      if(perfect && ccKey.isNotEmpty) {
        final filter = getRhymeIndices(consLast, IPA.keyCode(ccKey)).toSet();
        return list.where(filter.contains).toList();
      }

      return list;

    } else {
      final vocKey = IPA.keyVocals(ipak);
      if(vocKey.isEmpty) return [];

      final ccKey  = IPA.lastConsonantCluster(ipak);

      final searchKey = perfect ? vocKey : [vocKey.last];

      final list = getRhymeIndices(vocAll, IPA.keyCode(searchKey));

      if(perfect && ccKey.isNotEmpty) {
        final filter = getRhymeIndices(consLast, IPA.keyCode(ccKey)).toSet();
        return list.where(filter.contains).toList();
      }

      return list;
    }
  }

  /// Get list of sense indices for a given key
  List<int> getRhymeIndices(int list, String key) {
    final bytes = rhymes[list]![key];
    if (bytes == null)  return [];
    return bytes.buffer.asUint32List();
  }

  /// Helper: filter a list of sense indices
  List<int> _filterIndexes(List<int> indexes, RhymeSearchParams params) {
    return indexes.where((i) {
      final sense = dict.getSense(i)!;
      final entry = dict.getSenseEntry(i)!;

      if (params.syllables > 0
          && IPA.keySyllables(sense.ipak) != params.syllables) {
        return false;
      }

      final type = params.wordType;
      if (type != EntryType.all &&
          (!type.rarities.contains(entry.rarity) &&
              !type.tags.contains(sense.tag))) {
        return false;
      }

      final speech = params.speechType;
      if (speech != SpeechType.all && !speech.wordPoS.contains(sense.pos)) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Convert indices to GDict
  GDict _senseIndexesToDict(List<int> indexes) {
    final entryIndexes = indexes.map((i) => dict.getSenseEntryIndex(i)).toSet();
    final rhymesDict = GDict();
    for (final i in entryIndexes) {
      rhymesDict.addEntry(dict.getEntryByIndex(i)!);
    }
    return rhymesDict;
  }
}


// -----------------------------------------------------------------------------
// Class: RhymeSearchProps
// Description: Encapsulates the properties for a rhyme search
// -----------------------------------------------------------------------------
class RhymeSearchParams {
  String query = '';
  RhymeType rhymeType = RhymeType.perfect;
  SpeechType speechType = SpeechType.common;
  EntryType wordType = EntryType.common;
  bool phrases  = false;
  int syllables = 0; // 0 = All syllables
}

// -----------------------------------------------------------------------------
// Enum: RhymeType
// Description: Type of rhyme to search for
// -----------------------------------------------------------------------------
enum RhymeType {
  all('All'),
  perfect('Perfect'),
  near('Near'),
  vowel('Vowel'),
  conso('Consonant');

  final String displayName;
  const RhymeType(this.displayName);
}

// -----------------------------------------------------------------------------
// Enum: SpeechType
// Description: Filters rhymes based on part-of-speech categories
// -----------------------------------------------------------------------------
const Set<PartOfSpeech> commonSpeechTypes = {
  PartOfSpeech.noun, PartOfSpeech.verb, PartOfSpeech.adjective,
  PartOfSpeech.adverb, PartOfSpeech.pronoun
};

enum SpeechType {
  all('All', {}),
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

// -----------------------------------------------------------------------------
// Enum: WordType
// Description: Categorizes words for filtering or display purposes
// -----------------------------------------------------------------------------
enum EntryType {
  all('All', {}, {}),
  common('Common', {}, {Rarity.common}),
  uncommon('Uncommon', {}, {Rarity.uncommon, Rarity.rare, Rarity.obsolete}),
  slang('Slang', {SenseTag.slang}, {}),
  vulgar('Vulgar', {SenseTag.vulgar, SenseTag.offensive}, {});

  final String displayName;
  final Set<SenseTag> tags;
  final Set<Rarity> rarities;

  const EntryType(this.displayName, this.tags, this.rarities);
}
