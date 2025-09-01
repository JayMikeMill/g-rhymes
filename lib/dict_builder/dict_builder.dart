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
 * File: dict_builder.dart
 * Description: Builds multiple dictionaries asynchronously, including Wiktionary,
 *              WikiCommon, CMU, final dictionary, and rhyme dictionary.
 *              Provides progress updates via a callback and stores results in Hive.
 */

import 'dart:isolate';

import 'package:g_rhymes/data/g_dict.dart';
import 'package:g_rhymes/data/rhyme_dict.dart';
import 'package:g_rhymes/data/hive_storage.dart';
import 'package:g_rhymes/dict_builder/dict_parser.dart';

// -----------------------------------------------------------------------------
// Class: DictBuilder
// Description: Builds multiple dictionaries asynchronously, including Wiktionary,
//              WikiCommon, CMU, final dictionary, and rhyme dictionary. Provides
//              progress updates via a callback and stores results in Hive.
// -----------------------------------------------------------------------------
class DictBuilder {
  /// Maximum number of words to process (-1 = unlimited)
  static int maxWords = -1;

  /// Interval in milliseconds for status updates
  static int statusInterval = 5000;

  /// Flags for which dictionaries to build
  static bool buildWikitionary = true;
  static bool buildWikiCommon = true;
  static bool buildCMUDict = true;
  static bool buildFinalDict = true;
  static bool buildRhymeDict = true;

  /// Applies configuration options to the parser
  static void _setParserOptions() {
    DictParser.maxWords = maxWords;
    DictParser.statusInterval = statusInterval;
  }

  /// Starts building dictionaries asynchronously, reporting progress via callback
  static void build(Function(String) updateCallback) async {
    _setParserOptions();

    final receivePort = ReceivePort();

    // Listen for messages from the isolate
    receivePort.listen((message) {
      if (message is String) {
        updateCallback(message);
      }
    });

    // Spawn isolate to do the heavy lifting
    await Isolate.spawn(_buildDictionaries, [receivePort.sendPort]);
  }

  /// Internal method executed in an isolate to build all requested dictionaries
  static void _buildDictionaries(List<dynamic> args) async {
    final SendPort sendPort = args[0];
    final updateCallback = sendPort.send;

    updateCallback('Started building dictionaries...');

    if (buildWikitionary) {
      GDict dict = await DictParser.parseWiktionary(updateCallback);
      updateCallback('Sorting and saving dictionary...');
      dict.sortWordsByName();
      HiveStorage.putHiveObj('dicts', 'wiki_dict', dict);
      updateCallback('Finished building Wiktionary.');
    }

    if (buildWikiCommon) {
      GDict dict = await DictParser.parseWikiCommon(updateCallback);
      updateCallback('Sorting and saving dictionary...');
      dict.sortWordsByName();
      HiveStorage.putHiveObj('dicts', 'wiki_common', dict);
      updateCallback('Finished building Wiki common words.');
    }

    if (buildCMUDict) {
      GDict dict = await DictParser.parseCMUDict(updateCallback);
      updateCallback('Sorting and saving dictionary...');
      dict.sortWordsByName();
      HiveStorage.putHiveObj('dicts', 'cmu_pron', dict);
      updateCallback('Finished building CMU pronunciation dict (${dict.count()} words)');
    }

    if (buildFinalDict) {
      sendPort.send('Building final dictionary...');
      GDict wDict = await HiveStorage.getHiveObj('dicts', 'wiki_dict');
      GDict cDict = await HiveStorage.getHiveObj('dicts', 'wiki_common');
      GDict filteredDict = wDict.filteredBy(cDict);

      GDict cmuDict = await HiveStorage.getHiveObj('dicts', 'cmu_pron');

      for (DictEntry word in filteredDict.entries) {
        if (cmuDict.hasEntry(word.token)) {
          // word.ipa = cmuDict.getWordByName(word.name)!.ipa;
        }
      }

      updateCallback('Sorting and saving dictionary...');
      cDict.sortWordsByName();
      HiveStorage.putHiveObj('dicts', 'final', filteredDict);
      updateCallback('Finished building final dict (${filteredDict.count()} words)');
    }

    if (buildRhymeDict) {
      updateCallback('Building rhyme dictionary from final...');
      GDict dict = await HiveStorage.getHiveObj('dicts', 'final');
      RhymeDict rDict = RhymeDict(dict);
      updateCallback('Saving dictionary...');
      await HiveStorage.putRhymeDict('english', rDict);
      updateCallback('Finished build rhyme dict (${rDict.dict.count()} words)');
      await loadRhymeDict();
    }

    updateCallback('Compacting Hive boxes...');

    await HiveStorage.compactBox('rhyme_dicts');
    await HiveStorage.compactBox('dicts');

    updateCallback('Finished building dictionaries!');
  }
}
