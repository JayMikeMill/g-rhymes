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
import 'package:g_rhymes/providers/rhyme_search_provider.dart';

// -----------------------------------------------------------------------------
// Class: DictBuilder
// Description: Builds multiple dictionaries asynchronously, including Wiktionary,
//              WikiCommon, CMU, final dictionary, and rhyme dictionary. Provides
//              progress updates via a callback and stores results in Hive.
// -----------------------------------------------------------------------------
class DictBuildOptions {
  /// Flags for which dictionaries to build
  bool buildWikitionary = true;
  bool buildWikiCommon = true;
  bool buildCMUDict = true;
  bool buildFinalDict = true;
  bool buildRhymeDict = true;

  /// Interval in milliseconds for status updates
  int statusInterval = 5000;

}

// -----------------------------------------------------------------------------
// Class: DictBuilder
// Description: Builds multiple dictionaries asynchronously, including Wiktionary,
//              WikiCommon, CMU, final dictionary, and rhyme dictionary. Provides
//              progress updates via a callback and stores results in Hive.
// -----------------------------------------------------------------------------
class DictBuilder {
  /// Maximum number of words to process (-1 = unlimited)
  SendPort? _stopPort;


  /// Starts building dictionaries asynchronously, reporting progress via callback
  void build(DictBuildOptions opts, Function(String) updateCallback) async {
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
        [opts, statusPort.sendPort, controlPort.sendPort]);
  }

  /// Internal method executed in an isolate to build all requested dictionaries
  static void _buildDictionaries(List<dynamic> args) async {
    final DictBuildOptions opts = args[0]; // for status updates
    final SendPort statusPort = args[1]; // for status updates
    final SendPort controlPort = args[2]; // for control (stop) messages
    final updateCallback = statusPort.send;

    DictParser parser = DictParser();
    parser.statusInterval = opts.statusInterval;

    // Listen for stop signal
    bool stopped = false;

    // Isolate's ReceivePort to listen for stop messages
    final isolateControl = ReceivePort();
    controlPort.send(isolateControl.sendPort); // send port back to main
    isolateControl.listen((msg) {
      if (msg == 'stop') {
        stopped = true;
        updateCallback('Stopped Building.');
      }
    });

    bool shouldStop() => stopped;

    updateCallback('Started Building...');

    if (opts.buildWikitionary) {
      GDict dict = await parser.parseWiktionary(updateCallback, shouldStop);
      if(shouldStop()) return;

      updateCallback('Saving Dict...');
      dict.sortWordsByName();
      await HiveStorage.putHiveObj('dicts', 'wiki_dict', dict);
      updateCallback('Finished Wiktionary.');
    }

    if (opts.buildWikiCommon) {
      GDict dict = await parser.parseWikiCommon(updateCallback, shouldStop);
      if(shouldStop()) return;
      updateCallback('Saving Dict...');
      dict.sortWordsByName();
      await HiveStorage.putHiveObj('dicts', 'wiki_common', dict);
      updateCallback('Finished Wiki Common Dict.');
    }

    if (opts.buildCMUDict) {
      GDict dict = await parser.parseCMUDict(updateCallback, shouldStop);
      if(shouldStop()) return;
      updateCallback('Saving Dict...');
      dict.sortWordsByName();
      await HiveStorage.putHiveObj('dicts', 'cmu_pron', dict);
      updateCallback('Finished CMU Dict (${dict.count()} words)');
    }

    if (opts.buildFinalDict) {
      updateCallback('Building Final Dict...');
      GDict wDict = await HiveStorage.getHiveObj('dicts', 'wiki_dict');
      GDict cmuDict = await HiveStorage.getHiveObj('dicts', 'cmu_pron');
      //GDict cDict = await HiveStorage.getHiveObj('dicts', 'wiki_common');
      GDict filteredDict = wDict.filteredBy(cmuDict, phrases: false);

      // for (DictEntry word in filteredDict.entries) {
      //    if (cmuDict.hasEntry(word.token)) {
      //      // word.ipa = cmuDict.getWordByName(word.name)!.ipa;
      //    }
      //  }

      if(shouldStop()) return;

      updateCallback('Saving Dictionary...');
      //cDict.sortWordsByName();
      await HiveStorage.putHiveObj('dicts', 'final', filteredDict);
      updateCallback('Finished Final Dict (${filteredDict.count()} words)');
    }

    if (opts.buildRhymeDict) {
      updateCallback('Building Rhyme Dict...');
      GDict dict = await HiveStorage.getHiveObj('dicts', 'final');
      if(shouldStop()) return;
      RhymeDict rDict = RhymeDict(dict: dict);
      if(shouldStop()) return;
      updateCallback('Saving Dict...');
      await HiveStorage.putRhymeDict('english', rDict);
      if(shouldStop()) return;
      updateCallback('Finished Rhyme Dict (${rDict.dict.count()} words)');
    }

    if(shouldStop()) return;

    updateCallback('Compacting Hive boxes...');

    await HiveStorage.compactBox('rhyme_dicts');
    await HiveStorage.compactBox('dicts');

    await loadRhymeDict();

    updateCallback('Finished building dictionaries!');
  }

  void stopBuilding() {
    _stopPort?.send('stop');
    _stopPort = null;
  }
}
