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

  static SendPort? _stopPort;

  /// Applies configuration options to the parser
  static void _setParserOptions() {
    DictParser.maxWords = maxWords;
    DictParser.statusInterval = statusInterval;
  }

  /// Starts building dictionaries asynchronously, reporting progress via callback
  static void build(Function(String) updateCallback) async {
    _setParserOptions();


    final statusPort = ReceivePort(); // receives status updates

    // Listen for messages from the isolate
    statusPort.listen((message) {
      if (message is String) {
        updateCallback(message);
      }
    });

    // Control port for sending stop commands
    final controlPort = ReceivePort();

    // This port will receive the SendPort from the isolate
    controlPort.listen((msg) {
      if (msg is SendPort) _stopPort = msg;
    });

    stopBuilding();

    await Isolate.spawn(_buildDictionaries,
        [statusPort.sendPort, controlPort.sendPort]);
  }

  /// Internal method executed in an isolate to build all requested dictionaries
  static void _buildDictionaries(List<dynamic> args) async {
    final SendPort statusPort = args[0]; // for status updates
    final SendPort controlPort = args[1]; // for control (stop) messages
    final updateCallback = statusPort.send;

    // Listen for stop signal
    bool stopped = false;

    // Isolate's ReceivePort to listen for stop messages
    final isolateControl = ReceivePort();
    controlPort.send(isolateControl.sendPort); // send port back to main
    isolateControl.listen((msg) {
      if (msg == 'stop') {
        stopped = true;
        updateCallback('Stopped building dictionaries.');
      }
    });

    bool shouldStop() => stopped;

    updateCallback('Started building dictionaries...');

    if (buildWikitionary) {
      GDict dict = await DictParser.parseWiktionary(updateCallback, shouldStop);
      if(shouldStop()) return;

      updateCallback('Sorting and saving dictionary...');
      dict.sortWordsByName();
      HiveStorage.putHiveObj('dicts', 'wiki_dict', dict);
      updateCallback('Finished building Wiktionary.');
    }

    if (buildWikiCommon) {
      GDict dict = await DictParser.parseWikiCommon(updateCallback, shouldStop);
      if(shouldStop()) return;
      updateCallback('Sorting and saving dictionary...');
      dict.sortWordsByName();
      HiveStorage.putHiveObj('dicts', 'wiki_common', dict);
      updateCallback('Finished building Wiki common words.');
    }

    if (buildCMUDict) {
      GDict dict = await DictParser.parseCMUDict(updateCallback, shouldStop);
      if(shouldStop()) return;
      updateCallback('Sorting and saving dictionary...');
      dict.sortWordsByName();
      HiveStorage.putHiveObj('dicts', 'cmu_pron', dict);
      updateCallback('Finished building CMU pronunciation dict (${dict.count()} words)');
    }

    if (buildFinalDict) {
      updateCallback('Building final dictionary...');
      GDict wDict = await HiveStorage.getHiveObj('dicts', 'wiki_dict');
      //GDict cDict = await HiveStorage.getHiveObj('dicts', 'wiki_common');
      //GDict filteredDict = wDict.filteredBy(cDict);

      //GDict cmuDict = await HiveStorage.getHiveObj('dicts', 'cmu_pron');

      // for (DictEntry word in filteredDict.entries) {
      //   if(shouldStop()) return;
      //   if (cmuDict.hasEntry(word.token)) {
      //     // word.ipa = cmuDict.getWordByName(word.name)!.ipa;
      //   }
      // }

      if(shouldStop()) return;

      updateCallback('Sorting and saving dictionary...');
      //cDict.sortWordsByName();
      HiveStorage.putHiveObj('dicts', 'final', wDict);
      updateCallback('Finished building final dict (${wDict.count()} words)');
    }

    if (buildRhymeDict) {
      updateCallback('Building rhyme dictionary from final...');
      GDict dict = await HiveStorage.getHiveObj('dicts', 'final');
      if(shouldStop()) return;
      RhymeDict rDict = RhymeDict(dict);
      if(shouldStop()) return;
      updateCallback('Saving dictionary...');
      await HiveStorage.putRhymeDict('english', rDict);
      if(shouldStop()) return;
      updateCallback('Finished build rhyme dict (${rDict.dict.count()} words)');
      await loadRhymeDict();
    }

    if(shouldStop()) return;

    updateCallback('Compacting Hive boxes...');

    await HiveStorage.compactBox('rhyme_dicts');
    await HiveStorage.compactBox('dicts');

    updateCallback('Finished building dictionaries!');
  }

  static void stopBuilding() {
    _stopPort?.send('stop');
    _stopPort = null;
  }
}
