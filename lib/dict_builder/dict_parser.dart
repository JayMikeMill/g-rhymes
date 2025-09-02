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
 * File: dict_parser.dart
 * Description: Parses multiple dictionary sources, including Wiktionary,
 *              WikiCommon, and CMU pronunciation dictionary. Converts
 *              phonemes to IPA and applies rarity/tags for dictionary entries.
 */

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:g_rhymes/data/ipa.dart';
import 'package:path/path.dart' as path;
import 'package:g_rhymes/helpers/log.dart';
import 'package:g_rhymes/data/g_dict.dart';

// -----------------------------------------------------------------------------
// Class: DictParser
// Description: Parses dictionary sources and constructs GDict objects.
//              Handles Wiktionary JSONL, WikiCommon TXT, and CMU pronunciation
//              data. Applies filtering, rarity, and IPA conversion.
// -----------------------------------------------------------------------------
class DictParser {
  /// File paths for source dictionaries
  static String wikiDict =
  path.join(Directory.current.path, 'source_dicts', 'wiktionary.jsonl');
  static String wikiCommonDict =
  path.join(Directory.current.path, 'source_dicts', 'wiki-100k-common.txt');
  static String googleCommonDict =
  path.join(Directory.current.path, 'source_dicts', 'google-10k-common.txt');
  static String CMUDict =
  path.join(Directory.current.path, 'source_dicts', 'cmudict.txt');


  // -------------------- CONFIG --------------------
  /// Interval in lines for status updates
  int statusInterval = 5000;

  /// Temporary objects reused during parsing
  GDict _tempDict = GDict();
  DictEntry _tempEntry = DictEntry();
  DictSense _tempSense = DictSense();


  // ---------------------------------------------------------------------------
  /// Parses Wiktionary JSONL file asynchronously and builds a GDict
  /// Reports progress via [updateCallback].
  Future<GDict> parseWiktionary(Function(String) updateCallback,
      bool Function() stop) async {
    updateCallback('Building Wiktionary...');

    int linesRead = 0;
    int wordCount = 0;
    _tempDict = GDict();

    final Stream<String> input = File(wikiDict).openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter());

    updateCallback('Processed $linesRead lines ($wordCount words)...');

    await for (final line in input) {
      if(stop()) return _tempDict;

      linesRead++;

      final word = parseWikiLine(line);


      if (linesRead % statusInterval == 0) {
        updateCallback('/cProcessed $linesRead lines ($wordCount words)...');
      }

      if (word == null) continue;
      if (_tempDict.hasEntry(word.token)) continue;

      _tempDict.addEntry(word);

      wordCount++;
    }

    updateCallback('Finished! ($linesRead lines, ${_tempDict.count()} words).');

    return _tempDict;
  }

  // ---------------------------------------------------------------------------
  /// Parses a single Wiktionary JSONL line into a [DictEntry]
  /// Returns null if the line is invalid or filtered out.
  DictEntry? parseWikiLine(String line) {
    dynamic data;

    try {
      line = line.trim();
      data = jsonDecode(line);
    } catch (e) {
      Log.e('JSON parse failed');
      return null;
    }

    // Reset temporary objects
    _tempEntry = DictEntry();
    _tempSense = DictSense();

    // Extract word token
    _tempEntry.setToken(data['word'] ?? '');
    if (_tempEntry.token.isEmpty) return null;

    bool appendSense = false;
    if (_tempDict.hasEntry(_tempEntry.token)) {
      _tempEntry = _tempDict.getEntry(_tempEntry.token)!;
      appendSense = true;
    }

    // Extract IPA from sounds
    List<dynamic>? sounds = data['sounds'] ?? [];
    if (sounds == null || sounds.isEmpty) return null;

    String foundIpa = '';
    for (final Map<String, dynamic> item in sounds) {
      if(!item.containsKey('ipa')) continue;
      String tempIpa = item['ipa'] ?? '';
      if(tempIpa.isEmpty) continue;

      // avoid duplicate pronunciations
      if(appendSense) {
        if(_tempEntry.ipas.contains(IPA.keyedIpa(tempIpa))) {
          continue;
        }
      }

      foundIpa = tempIpa;
      break;
    }

    //if (foundIpa.isEmpty) return null;

    _tempSense.ipa = IPA.keyedIpa(foundIpa);

    // Extract part of speech
    String? wikiPos = data['pos'];
    if (wikiPos == null) return null;
    _tempSense.pos = PartOfSpeech.fromWikiPos(wikiPos);

    // No duplicate parts of speech
    if(_tempEntry.allPOS.contains(_tempSense.pos)) return null;

    // Extract first sense (definition and tags)
    List<dynamic> senses = data['senses'] ?? [];

    if (senses.isNotEmpty) {
      var firstSense = senses[0];

      // Extract tags for rarity and sense
      List<String> wikiTags = List<String>.from(firstSense['tags'] ?? []);
      if(!appendSense) _tempEntry.rarity = Rarity.fromWikiTags(wikiTags);
      _tempSense.tag = SenseTag.fromWikiTags(wikiTags);

      // Extract definition text
      var definition = firstSense['definition'] ?? firstSense['glosses'];
      if (definition is List && definition.isNotEmpty) {
        _tempSense.meaning = definition[0];
      } else if (definition is String) {
        _tempSense.meaning = definition;
      }
    }

    _tempEntry.addSense(_tempSense);

    // if sense was appended dont return entry to be readded
    return _tempEntry;
  }

  // ---------------------------------------------------------------------------
  /// Assigns rarity to WikiCommon words based on index
  Rarity _getWikiCommonWordRarity(int index) {
    if (index < 15000) return Rarity.common;
    if (index < 40000) return Rarity.uncommon;
    return Rarity.rare;
  }

  // ---------------------------------------------------------------------------
  /// Parses WikiCommon word list asynchronously
  Future<GDict> parseWikiCommon(
      Function(String) updateCallback, bool Function() stop) async {
    updateCallback('Building Wiki Common...');

    _tempDict = GDict();
    final Stream<String> input = File(wikiCommonDict).openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter());

    int wordCount = 0;
    await for (final line in input) {
      if(stop()) return _tempDict;
      if (line.startsWith('#')) continue;
      _tempEntry = DictEntry();
      _tempEntry.token = line.toLowerCase();
      if (_tempDict.hasEntry(_tempEntry.token)) continue;
      _tempEntry.rarity = _getWikiCommonWordRarity(wordCount);
      _tempDict.addEntry(_tempEntry);
      wordCount++;
    }

    updateCallback('Finished (${_tempDict.count()} words).');
    return _tempDict;
  }

  // ---------------------------------------------------------------------------
  /// Parses CMU pronunciation dictionary asynchronously
  Future<GDict> parseCMUDict(
      Function(String) updateCallback, bool Function() stop) async {
    updateCallback('Building CMU...');

    _tempDict = GDict();
    final Stream<String> input = File(CMUDict).openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter());

    await for (final line in input) {
      if(stop()) return _tempDict;
      if (line.startsWith(';;;') || line.trim().isEmpty) continue;

      final parts = line.split(RegExp(r'\s+'));
      if (parts.length < 2) continue;

      _tempEntry = DictEntry();
      _tempSense = DictSense();

      // Remove numbered suffixes (e.g., WORD(1)) and lowercase
      _tempEntry.token = parts.first.replaceAll(RegExp(r'\(\d+\)$'), '').toLowerCase();

      // add multiple pronunciations
      if (_tempDict.hasEntry(_tempEntry.token)) {
        _tempEntry = _tempDict.getEntry(_tempEntry.token)!;
      }

      _tempSense.ipa = _cmuToIpaString(parts.sublist(1));
      _tempEntry.addSense(_tempSense);
      _tempDict.addEntry(_tempEntry);

      addCmuClusters(parts.sublist(1), _tempEntry.token);
    }
    print(CMUClusts.toList()..sort());
    updateCallback('Finished CMU ${_tempDict.count()} words).');
    return _tempDict;
  }

  // ---------------------------------------------------------------------------

  /// CMU to IPA phoneme mapping aligned with clusterMap
  static const Map<String, String> cmuToIpa = {
    'AA':'ɑ', 'AE':'æ', 'AH':'ɐ', 'AO':'ɔ', 'AW':'aʊ', 'AY':'aɪ', 'EH':'ɛ',
    'ER':'ɝ', 'EY':'eɪ', 'IH':'ɪ', 'IY':'i', 'OW':'oʊ', 'OY':'ɔɪ', 'UH':'ʊ',
    'UW':'u', 'P':'p','B':'b','T':'t','D':'d','K':'k','G':'ɡ','CH':'tʃ',
    'JH':'dʒ','F':'f','V':'v','TH':'θ','DH':'ð', 'S':'s','Z':'z','SH':'ʃ',
    'ZH':'ʒ','HH':'h','M':'m','N':'n','NG':'ŋ','L':'l','R':'ɹ','Y':'j','W':'w',
    '0':'','1':'ˈ','2':'ˌ'
  };


  // ---------------------------------------------------------------------------
  /// Converts CMU phoneme list to IPA string
  static String _cmuToIpaString(List<String> cmuPhonemes) {
    final buffer = StringBuffer();
    for (var ph in cmuPhonemes) {
      // Strip stress digits if attached (e.g. "AH0" -> "AH")
      final match = RegExp(r'([A-Z]+)([0-2]?)').firstMatch(ph);
      if (match == null) continue;
      final base = match.group(1)!;
      final stress = match.group(2);

      final ipa = cmuToIpa[base];
      if (ipa == null) {
        Log.w('Unknown CMU phoneme: $base');
        continue;
      }

      // Add stress marker if present
      if (stress == '1') buffer.write('ˈ');
      else if (stress == '2') buffer.write('ˌ');

      buffer.write(ipa);
    }
    return buffer.toString();
  }

  static Set<String> CMUClusts = {};

  // Extract consonant clusters from a single CMU phoneme list
  static void addCmuClusters(List<String> cmuPhonemes, String token) {
    final ipaString = _cmuToIpaString(cmuPhonemes);

    // Match sequences of 2+ consonants
    final clusterMatches = RegExp(r'([pbtdkɡfvθðszʃʒhmnŋlɹjw]+)')
        .allMatches(ipaString);

    for (var match in clusterMatches) {
      final cluster = match.group(0)!;
      if (cluster.length > 1) {
        CMUClusts.add(cluster);
        print(cluster);
        print(token);
      }
    }
  }
}
