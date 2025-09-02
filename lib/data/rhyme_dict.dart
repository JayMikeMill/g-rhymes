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
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:g_rhymes/helpers/log.dart';

import 'ipa.dart';
import 'g_dict.dart';
import 'hive_storage.dart';

part 'rhyme_dict.g.dart'; // Hive-generated adapter file



// -----------------------------------------------------------------------------
// Class: RhymeDict
// Description: Stores a dictionary and precomputes rhymes for quick lookup
// -----------------------------------------------------------------------------

@HiveType(typeId: 6)
class RhymeDict extends HiveObject {

  /// Core dictionary containing words and senses
  @HiveField(0) GDict dict = GDict();

  /// Maps a base64-encoded IPA key to the indices of matching senses
 // @HiveField(1) Map<String, List<int>> sounds      = {};
  @HiveField(1) Map<String, List<int>> vocals      = {};
  @HiveField(2) Map<String, List<int>> last        = {};

  RhymeDict();

  RhymeDict.buildFrom(GDict fromDict) {
    build(fromDict);
  }

  /// Clears all precomputed rhyme data
  void clear() {
    //sounds.clear();
    vocals.clear();
    last.clear();
  }

  /// Builds rhymes by computing subkeys for each sense and storing them in maps
  void build(GDict fromDict) {
    dict = fromDict;

    clear();

    int senseIndex = 0;
    for (final sense in dict.senses) {
      // All subkeys of the sense
      List<Uint8List> sKeys = IPA.subKeys(sense.ipak);
      List<Uint8List> vKeys = IPA.subKeys(IPA.keyVocals(sense.ipak));
      //List<Uint8List> cKeys = IPA.subKeys(IPA.keyConsonants(sense.ipak));

      // Store indices in maps for fast rhyme lookup
      // for (final key in sKeys) {
      //   sounds.putIfAbsent(base64Encode(key), () => []).add(senseIndex);
      // }

      for (final key in vKeys) {
        vocals.putIfAbsent(base64Encode(key), () => []).add(senseIndex);
      }

      Uint8List lastConsonants = IPA.lastConsonantCluster(sense.ipak);

      if(lastConsonants.isNotEmpty) {
        last.putIfAbsent(base64Encode(lastConsonants), () => []).add(senseIndex);
      }

      senseIndex++;
    }
  }

  /// Retrieves rhyming dictionary entries for a given token and search properties
  GDict getRhymes(RhymeSearchParams params) {
    DictEntry? entry = dict.getEntry(params.query);

    if(entry == null) return GDict();

    bool perfect = params.rhymeType == RhymeType.perfect;

    List<int> rhymes = [];
    List<int> rhymeSet = [];

    for(final sense in entry.senses) {
      Uint8List vKeys = IPA.keyVocals(sense.ipak);
      if(vKeys.isEmpty) continue;

      // Select subkeys for rhyme search
      List<int> searchKey = [vKeys.last];
      if(perfect) searchKey = vKeys;
      print(searchKey);

      rhymeSet.addAll(vocals[base64Encode(searchKey)] ?? []);

      // Filter perfect rhymes by ending sounds
      if(perfect) {
        Uint8List lastConsonants = IPA.lastConsonantCluster(sense.ipak);

        print(lastConsonants);
        if(lastConsonants.isNotEmpty) {
          final matchSet = last[base64Encode(lastConsonants)]?.toSet() ?? {};
          rhymeSet = rhymeSet.where((i) => matchSet.contains(i)).toList();
        }
      }

      rhymes.addAll(rhymeSet);
    }

    // Filter by syllable count
    int syllables = params.syllables;
    if(syllables > 0) {
      rhymes.removeWhere((i) =>
      IPA.keySyllables(dict.getSense(i)!.ipak) != syllables);
    }

    // Filter by entry type
    EntryType type = params.wordType;
    if(type != EntryType.all) {
      rhymes.removeWhere((i) =>
      !type.rarities.contains(dict.getSenseEntry(i)!.rarity) &&
      !type.tags.contains(dict.getSense(i)!.tag));
    }


    // Filter by speech type
    SpeechType speech = params.speechType;
    if(speech != SpeechType.all) {
      rhymes.removeWhere((i) =>
      !speech.wordPoS.contains(dict.getSense(i)!.pos));
    }


    return _senseIndexesToDict(rhymes);
  }

  /// Converts a list of sense indices into a new GDict
  GDict _senseIndexesToDict(List<int> indexes) {
    Set<int> entryIndexes = {};
    for (final index in indexes.toSet()) {
      entryIndexes.add(dict.getSenseEntryIndex(index));
    }

    GDict rhymes = GDict();
    for (final index in entryIndexes) {
      rhymes.addEntry(dict.getEntryByIndex(index)!);
    }

    return rhymes;
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
