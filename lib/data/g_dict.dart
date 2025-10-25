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
 * File: g_dict.dart
 * Description: Defines the core dictionary structures (GDict, DictEntry,
 *              DictSense) and associated enums (Rarity, SenseTag,
 *              PartOfSpeech). Supports storage, lookups, filtering,
 *              sorting, and IPA conversions for words and senses.
 */

import 'dart:convert';
import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'ipa.dart';

part 'g_dict.g.dart'; // Hive-generated adapter file

// -----------------------------------------------------------------------------
// Class: GDict
// Description: Represents a full dictionary structure storing words, their
//              senses, and mappings for fast lookups. Supports adding, sorting,
//              filtering, and clearing of entries.
// -----------------------------------------------------------------------------
@HiveType(typeId: 0)
class GDict extends HiveObject {
  /// List of dictionary entries
  @HiveField(0) List<DictEntry> entries = [];

  /// Map of token strings to their index in `entries`
  @HiveField(1) Map<String, int> tokenMap = {};

  /// List of all senses across all entries
  @HiveField(2) List<List<int>> senseMap = [];

  /// List of all phrases stored as keys linked to entry indexes
  @HiveField(3) List<String> phrases = [];

  bool get isEmpty => entries.isEmpty;
  bool get isNotEmpty => entries.isNotEmpty;

  /// Returns the number of entries in the dictionary
  int get entryCount => entries.length;

  /// Adds a new dictionary entry along with its senses
  void addEntry(DictEntry entry) {
    // Can't have two of the same tokens
    if(entry.isPhrase) {
      addPhrase(entry.token);
      return;
    }

    if(hasEntry(entry.token)) return;

    int index = entries.length;

    entries.add(entry);
    tokenMap[entry.token.toLowerCase()] = index;

    for (int i = 0; i < entry.senses.length; i++) {
      senseMap.add([index, i]);
    }
  }

  /// Checks if a token exists in the dictionary
  bool hasEntry(String token) => tokenMap.containsKey(token.toLowerCase());

  /// Checks if a token exists in the dictionary
  bool hasEntryIndex(int index) => index >= 0 && index < entries.length;

  /// Retrieves a dictionary entry by token
  DictEntry getEntryByIndex(int index) => hasEntryIndex(index) ?
  entries[index] : DictEntry();

  /// Retrieves a dictionary entry by token
  DictEntry getEntry(String token) =>
      tokenMap.containsKey(token.toLowerCase()) ?
      entries[tokenMap[token.toLowerCase()]!] :
      getPhrase(token);

  void addPhrase(String phrase) {
    String key = keyPhrase(phrase);
    if(key.isNotEmpty) phrases.add(key);
  }

  /// Checks if a sense index is valid
  bool hasPhraseIndex(int index) => index >= 0 && index < phrases.length;
  DictEntry getPhraseFromIndex(int index) => hasPhraseIndex(index) ?
      getPhrase(phraseKey(phrases[index])) : DictEntry();

  DictEntry getPhrase(String phrase) {
    final entries = indexPhrase(phrase).map((i) => getEntryByIndex(i));
    if (entries.isEmpty) return DictEntry();

    // Build the phrase entry
    final entry = DictEntry();
    entry.token = entries.map((e) => e.token).join(' ');
    entry.addSense(DictSense());
    entry.senses[0].ipa = entries
        .where((e) => e.senses.isNotEmpty && e.senses[0].ipa.isNotEmpty)
        .map((e) => e.senses[0].ipa).join(' ');

    return entry;
  }

  List<int> indexPhrase(String phrase) {
    final tokensList = phrase.toLowerCase().split(' ');
    if (tokensList.any((t) => !hasEntry(t))) return [];
    return tokensList.map((t) => tokenMap[t]!).toList();
  }

  String keyPhrase(String phrase) {
    return base64Encode(Uint32List
        .fromList(indexPhrase(phrase)).buffer.asUint8List());
  }

  String phraseKey(String key) {
    final indexes = Uint32List.view(base64Decode(key).buffer);
    return indexes.map((i) => getEntryByIndex(i).token).join(' ');
  }

  /// Checks if a sense index is valid
  bool hasSense(int index) => index >= 0 && index < senseMap.length;

  /// Retrieves the parent entry for a given sense index
  DictEntry getSenseEntry(int index) => hasSense(index) ?
    entries[senseMap[index][0]] : DictEntry();

  /// Retrieves a sense by its index
  DictSense getSense(int index) => hasSense(index) ?
    getSenseEntry(index).senses[senseMap[index][1]] : DictSense();

  int getSenseEntryIndex(int index) =>
      hasSense(index) ? senseMap[index][0] : -1;

  /// Clears all dictionary data
  void clear() {
    entries.clear();
    tokenMap.clear();
    senseMap.clear();
    phrases.clear();
  }

  /// Sorts entries alphabetically by token and reindexes maps
  void sortEntries() {
    List<DictEntry> sorted = entries.toList()
      ..sort((a, b) => a.token.toLowerCase().compareTo(b.token.toLowerCase()));

    clear();

    for (final word in sorted) {
      addEntry(word);
    }
  }

  /// Returns a new GDict filtered by entries that exist in another dictionary
  GDict filter(bool Function(DictEntry) where) {
    final newDict = GDict();
    for(final entry in entries) {
      if(where(entry)) newDict.addEntry(entry);
    }
    return newDict;
  }

  /// Returns a new GDict with all entries
  GDict clone() {
    final newDict = GDict();
    entries.forEach(newDict.addEntry);
    newDict.phrases = List.from(phrases);
    return newDict;
  }

  void append(GDict dict){
    dict.entries.forEach(addEntry);
  }

}

// -----------------------------------------------------------------------------
// Class: DictEntry
// Description: Represents a single dictionary entry (word) with associated
//              rarity and multiple senses.
// -----------------------------------------------------------------------------

@HiveType(typeId: 1)
class DictEntry extends HiveObject {
  /// The token (word) string
  @HiveField(0) String token = '';

  /// Word rarity
  @HiveField(1) Rarity rarity = Rarity.common;

  /// List of senses for this word
  @HiveField(2) List<DictSense> senses = [];

  bool get isPhrase => token.contains(' ');
  bool get isEmpty => token.isEmpty;

  /// Iterable of IPA representations for each sense
  Iterable<String> get ipas => senses.map((s) => s.ipa);

  /// Iterable of IPA representations for each sense
  Iterable<Uint8List> get ipaks => senses.map((s) => s.ipak);

  /// Iterable of sense tags
  Iterable<String> get tagTokens => senses.map((s) => s.tag.token);

  /// Iterable of sense tags
  Iterable<PartOfSpeech> get allPOS => senses.map((s) => s.pos);

  /// Iterable of meanings for each sense
  Iterable<String> get definitions => senses.map((s) => s.definition);

  void setToken(String tok) => token = tok.trim();

  /// Adds a sense to this entry
  void addSense(DictSense sense) => senses.add(sense);
}

String packInts(List<int> ints) =>
    String.fromCharCodes(Uint32List.fromList(ints).buffer.asUint8List());

List<int> unpackInts(String packed) =>
    Uint32List.view(Uint8List.fromList(packed.codeUnits).buffer).toList();

// -----------------------------------------------------------------------------
// Class: DictSense
// Description: Represents a single sense of a word, including IPA, tags,
//              part of speech, and meaning.
// -----------------------------------------------------------------------------

@HiveType(typeId: 2)
class DictSense extends HiveObject {
  @HiveField(0) Uint8List ipak = Uint8List(0);
  @HiveField(1) PartOfSpeech pos = PartOfSpeech.other;
  @HiveField(2) SenseTag tag = SenseTag.none;
  @HiveField(3) String meaning = '';

  /// Returns IPA string representation
  String get definition =>
      "(${pos.token}${tag.token.isNotEmpty ? ', ${tag.token}' : ''}) "
          "($ipa) $meaning";

  /// Returns IPA string representation
  String get ipa => IPA.toIpa(ipak);

  /// Sets IPA from string representation
  set ipa(String sipa) => ipak = IPA.toKey(sipa);
}

// -----------------------------------------------------------------------------
// Enum: Rarity
// Description: Categorizes words by rarity (common, rare, etc.) with mapping
//              from wiki tags.
// -----------------------------------------------------------------------------
@HiveType(typeId: 3)
enum Rarity {
  @HiveField(0) common('common'),
  @HiveField(1) uncommon('uncommon'),
  @HiveField(2) rare('rare'),
  @HiveField(3) obsolete('obsolete');

  final String token;
  const Rarity(this.token);

  static const Map<String, Rarity> wikiTagMap = {
    'common': common,
    'uncommon': uncommon,
    'rare': rare,
    'obsolete': obsolete,
  };

  /// Returns Rarity based on a list of wiki tags
  static Rarity fromWikiTags(List<String> tags) {
    for (String tag in tags) {
      tag = tag.toLowerCase().trim();
      if (wikiTagMap.containsKey(tag)) return wikiTagMap[tag] ?? common;
    }
    return common;
  }
}

// -----------------------------------------------------------------------------
// Enum: SenseTag
// Description: Represents various word tags (offensive, slang, archaic, etc.)
// -----------------------------------------------------------------------------
@HiveType(typeId: 4)
enum SenseTag {
  @HiveField(0) none(''),
  @HiveField(1) offensive('offensive'),
  @HiveField(2) vulgar('vulgar'),
  @HiveField(3) slang('slang'),
  @HiveField(4) informal('informal'),
  @HiveField(5) archaic('archaic'),
  @HiveField(6) historical('historical'),
  @HiveField(7) literary('literary');

  final String token;
  const SenseTag(this.token);

  static const Map<String, SenseTag> wikiTagMap = {
    'derogatory': offensive,
    'offensive': offensive,
    'vulgar': vulgar,
    'slang': slang,
    'informal': informal,
    'archaic': archaic,
    'historical': historical,
    'literary': literary,
  };

  /// Returns SenseTag from a list of wiki tags
  static SenseTag fromWikiTags(List<String> tags) {
    for (String tag in tags) {
      tag = tag.toLowerCase().trim();
      if (wikiTagMap.containsKey(tag)) return wikiTagMap[tag] ?? none;
    }
    return none;
  }
}

// -----------------------------------------------------------------------------
// Enum: PartOfSpeech
// Description: Represents the grammatical category of a word or phrase.
// -----------------------------------------------------------------------------
@HiveType(typeId: 5)
enum PartOfSpeech {
  @HiveField(0) other('other'),
  @HiveField(1) noun('noun'),
  @HiveField(2) verb('verb'),
  @HiveField(3) adjective('adj.'),
  @HiveField(4) name('name'),
  @HiveField(5) adverb('adv.'),
  @HiveField(6) interjection('intj'),
  @HiveField(7) contraction('contraction'),
  @HiveField(8) preposition('prep'),
  @HiveField(9) pronoun('pron'),
  @HiveField(10) phrase('phrase'),
  @HiveField(11) numeral('num.'),
  @HiveField(12) determiner('det.'),
  @HiveField(13) conjunction('conj.'),
  @HiveField(14) particle('particle');

  final String token;
  const PartOfSpeech(this.token);

  static const Map<String, PartOfSpeech> wikiPosMap = {
    'noun': noun,
    'verb': verb,
    'adj': adjective,
    'name': name,
    'adv': adverb,
    'intj': interjection,
    'contraction': contraction,
    'prep': preposition,
    'pron': pronoun,
    'phrase': phrase,
    'prep_phrase': phrase,
    'proverb': phrase,
    'num': numeral,
    'det': determiner,
    'conj': conjunction,
    'particle': particle,
  };

  /// Returns PartOfSpeech from a wiki POS string
  static PartOfSpeech fromWikiPos(String pos) {
    return wikiPosMap[pos.toLowerCase()] ?? other;
  }
}
