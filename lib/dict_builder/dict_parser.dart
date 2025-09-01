import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:g_rhymes/helpers/log.dart';
import 'package:g_rhymes/data/g_dict.dart';

String wikiDict =
path.join(Directory.current.path, 'source_dicts', 'wiktionary.jsonl');
String wikiCommonDict =
path.join(Directory.current.path, 'source_dicts', 'wiki-100k-common.txt');
String googleCommonDict =
path.join(Directory.current.path, 'source_dicts', 'google-10k-common.txt');
String CMUDict =
path.join(Directory.current.path, 'source_dicts', 'cmudict.txt');

class DictParser {
  // -------------------- CONFIG --------------------
  static int maxWords         = -1;    // -1 = process all valid words
  static int statusInterval   = 5000;  // Print status every X lines

  static DictEntry _tempEntry = DictEntry();
  static DictSense _tempSense = DictSense();

  static Future<GDict> parseWiktionary(Function(String) updateCallback) async {
    updateCallback('Building Wiktionary...');

    int linesRead = 0;
    int wordCount = 0;
    GDict dict = GDict();

    final Stream<String> input = File(wikiDict).openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter());

    updateCallback('Processed $linesRead lines (words added: $wordCount)...');

    await for (final line in input) {
      linesRead++;

      final word = parseWikiLine(line, (name) {
        if(name.isEmpty) return false;
        if(dict.hasEntry(name)) return false;
        //if(!commonDict.containsKey(name.toLowerCase())) return false;
        return true;
      });

      if (word == null) continue;

      wordCount++;
      dict.addEntry(word);

      if (linesRead % statusInterval == 0) {
        updateCallback('/cProcessed $linesRead lines (words added: $wordCount)...');
      }

      if (maxWords != -1 && wordCount >= maxWords) break;
    }

    updateCallback('Finished ($linesRead lines, ${dict.count()} words).');

    return dict;
  }

  static DictEntry? parseWikiLine(String line, bool Function(String) tokenCheck) {
    dynamic data;

    try {
      line = line.trim();
      data = jsonDecode(line);
    } catch (e) {
      Log.e('JSON parse failed');
      return null;
    }

    // reset word
    _tempEntry = DictEntry();
    _tempSense = DictSense();

    // Extract word text
    _tempEntry.token = data['word'] ?? '';
    if(!tokenCheck(_tempEntry.token)) return null;

    // Extract IPA from sounds
    List<dynamic>? sounds = data['sounds'] ?? [];
    if(sounds == null || sounds.isEmpty) return null;

    String ipa = "";
    for(Map<String, dynamic> item in sounds) {
      if(item.containsKey('ipa')) {
        ipa = item['ipa'] ?? ''; break;
      }
    }

    if(ipa.isEmpty) return null;
    _tempSense.ipa = ipa.substring(1, ipa.length - 1);

    // Extract Part of Speach
    String? wikiPos = data['pos'];
    if (wikiPos == null) return null;
    _tempSense.pos = PartOfSpeech.fromWikiPos(wikiPos);

    // Grab the first sense (definitions and tags)
    List<dynamic> senses = data['senses'] ?? [];

    if (senses.isNotEmpty) {
      var firstSense = senses[0];

      // Extract Definition tags
      List<String> wikiTags = List<String>.from(firstSense['tags'] ?? []);
      _tempEntry.rarity = Rarity.fromWikiTags(wikiTags);
      _tempSense.tag = SenseTag.fromWikiTags(wikiTags);

      // Extract first Definition
      var definition = firstSense['definition'] ?? firstSense['glosses'];
      if (definition is List && definition.isNotEmpty) {
        _tempSense.meaning = definition[0];
      } else if (definition is String) {
        _tempSense.meaning = definition;
      }
    }

    _tempEntry.addSense(_tempSense);

    return _tempEntry;
  }


 static Rarity _getWikiCommonWordRarity(int index) {
    if(index < 15000) return Rarity.common;
    if(index < 40000) return Rarity.uncommon;
    return Rarity.rare;
 }

  static Future<GDict> parseWikiCommon
      (Function(String) updateCallback) async {

    updateCallback('Building Wiki common words dictionary...');

    GDict dict = GDict();

    final Stream<String> input = File(wikiCommonDict).openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter());

    int wordCount = 0;

    await for (final line in input) {
      if(line.startsWith('#')) continue;
      _tempEntry = DictEntry();
      _tempEntry.token = line.toLowerCase();
      if(dict.hasEntry(_tempEntry.token)) continue;
      _tempEntry.rarity = _getWikiCommonWordRarity(wordCount);
      dict.addEntry(_tempEntry); wordCount++;
    }

    updateCallback('Finished (${dict.count()} words).');

    return dict;
  }

  static Future<GDict> parseCMUDict
      (Function(String) updateCallback) async {

    updateCallback('Building CMU english pronunciation dictionary...');

    GDict dict = GDict();

    final Stream<String> input = File(CMUDict).openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter());

    await for (final line in input) {
      if (line.startsWith(';;;') || line.trim().isEmpty) continue;
      final parts = line.split(RegExp(r'\s+'));
      if (parts.length < 2) continue;
      _tempEntry = DictEntry();
      _tempSense = DictSense();

      // Remove (1), (2) ... from word
      _tempEntry.token = parts.first.replaceAll(RegExp(r'\(\d+\)$'), '').toLowerCase();
      if(dict.hasEntry(_tempEntry.token)) continue;

      _tempSense.ipa =cmuToIpaString(parts.sublist(1));
      _tempEntry.addSense(_tempSense);
      dict.addEntry(_tempEntry);
    }

    updateCallback('Finished (${dict.count()} words).');

    return dict;
  }

  static const Map<String, String> cmuToIpa = {
    'AA':'ɑ','AE':'æ','AH':'ʌ','AO':'ɔ','AW':'aʊ','AY':'aɪ',
    'EH':'ɛ','ER':'ɝ','EY':'eɪ','IH':'ɪ','IY':'i','OW':'oʊ',
    'OY':'ɔɪ','UH':'ʊ','UW':'u',
    'P':'p','B':'b','T':'t','D':'d','K':'k','G':'ɡ',
    'CH':'t͡ʃ','JH':'d͡ʒ','F':'f','V':'v','TH':'θ','DH':'ð',
    'S':'s','Z':'z','SH':'ʃ','ZH':'ʒ','HH':'h',
    'M':'m','N':'n','NG':'ŋ','L':'l','R':'ɹ','Y':'j','W':'w',
    '0':'','1':'ˈ','2':'ˌ'
  };

  static String cmuToIpaString(List<String> cmuPhonemes) {
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
      if (stress == '1') {
        buffer.write('ˈ');
      } else if (stress == '2') {
        buffer.write('ˌ');
      }

      buffer.write(ipa);
    }
    return buffer.toString();
  }
}
