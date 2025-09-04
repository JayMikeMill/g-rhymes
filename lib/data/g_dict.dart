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
  @HiveField(0)
  List<DictEntry> entries = [];

  /// Map of token strings to their index in `entries`
  @HiveField(1)
  Map<String, int> tokenMap = {};

  /// List of all senses across all entries
  @HiveField(2)
  List<DictSense> senses = [];

  /// Maps senses to the index of their parent entry in `entries`
  @HiveField(3)
  List<int> senseMap = [];

  bool get isEmpty => entries.isEmpty;
  bool get isNotEmpty => entries.isNotEmpty;

  /// Returns the last entry in the dictionary
  DictEntry get last => entries.last;

  /// Returns the number of entries in the dictionary
  int get entryCount => entries.length;

  /// Iterable view of all tokens (words) in the dictionary
  Iterable<String> get tokens => entries.map((w) => w.token);

  /// Adds a new dictionary entry along with its senses
  void addEntry(DictEntry entry) {
    // Can't have two of the same tokens
    if(hasEntry(entry.token)) return;

    int index = entries.length;

    entries.add(entry);
    tokenMap[entry.token.toLowerCase()] = index;

    for (final sense in entry.senses) {
      senses.add(sense);
      senseMap.add(index);
    }
  }

  /// Retrieves a dictionary entry by token
  DictEntry? getEntry(String token) =>
      tokenMap[token.toLowerCase()] != null ? entries[tokenMap[token.toLowerCase()]!] : null;

  /// Retrieves a dictionary entry by token
  DictEntry? getEntryByIndex(int index) => entries[index];


  /// Checks if a token exists in the dictionary
  bool hasEntry(String token) => tokenMap.containsKey(token.toLowerCase());

  /// Checks if a sense index is valid
  bool hasSense(int index) => index >= 0 && index < senseMap.length;

  /// Retrieves a sense by its index
  DictSense? getSense(int index) => hasSense(index) ? senses[index] : null;

  /// Retrieves the parent entry for a given sense index
  DictEntry? getSenseEntry(int index) =>
      hasSense(index) ? entries[senseMap[index]] : null;

  int getSenseEntryIndex(int index) =>
      hasSense(index) ? senseMap[index] : -1;

  /// Clears all dictionary data
  void clear() {
    entries.clear();
    tokenMap.clear();
    senses.clear();
    senseMap.clear();
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
    return newDict;
  }

  void append(GDict dict) => dict.entries.forEach(addEntry);

  List<DictEntry> getEntryList(String tokens) {
    List<DictEntry> entries = [];
    List<String> tokensList = tokens.split(' ');
    for (var t in tokensList) { if(hasEntry(t)) entries.add(getEntry(t)!); }
    return entries;
  }

  String getPhraseIpa(String tokens) {
    // get entry for each word in phrase
    String phraseIpa = getEntryList(tokens)
        .where((e) => e.senses.isNotEmpty && e.senses[0].ipa.isNotEmpty)
        .map((e) => e.senses[0].ipa).join(' ');

    return phraseIpa;

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

  void setToken(String tok) => token = tok.trim().toLowerCase();

  /// Adds a sense to this entry
  void addSense(DictSense sense) => senses.add(sense);
}

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
