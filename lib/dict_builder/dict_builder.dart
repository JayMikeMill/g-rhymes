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
import 'package:g_rhymes/data/ipa.dart';
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
  bool buildWikitionary = false;

  bool buildWikiCommon  = false;

  bool buildPhraseDict  = true;
  int  maxPhrases       = 1000000;
  int  maxPhraseTokens  = 3;

  bool buildCMUDict     = false;
  
  bool buildFinalDict   = true;
  bool buildRhymeDict   = true;

  bool compactBoxes     = false;

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
    statusPort.listen((message) async {
      if (message is String) {
        if(message == "_FINISHED_") {
          await RhymeDict.loadRhymeDict();
        } else {
          updateCallback(message);
        }
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
  void _buildDictionaries(List<dynamic> args) async {
    final DictBuildOptions opts = args[0]; // for status updates
    final SendPort statusPort   = args[1]; // for status updates
    final SendPort controlPort  = args[2]; // for control (stop) messages
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
        HiveStorage.closeHive();
        updateCallback('Stopped Building.');
      }
    });

    bool shouldStop() => stopped;

    updateCallback('Started Building dictionaries...');

    if (opts.buildWikitionary) {
      GDict dict = await parser.parseWiktionary(updateCallback, shouldStop);
      if(shouldStop()) return;

      updateCallback('Saving dictionary...');
      dict.sortEntries();
      await HiveStorage.putHiveObj('dicts', 'wiki_dict', dict);
      updateCallback('Finished Wiktionary.');
    }

    if (opts.buildWikiCommon) {
      GDict dict = await parser.parseWikiCommon(updateCallback, shouldStop);
      if(shouldStop()) return;
      updateCallback('Saving dictionary...');
      dict.sortEntries();
      await HiveStorage.putHiveObj('dicts', 'wiki_common', dict);
      updateCallback('Finished Wiki Common dictionary.');
    }

    if (opts.buildPhraseDict) {
      GDict dict = await parser.parsePhraseDict(opts, updateCallback, shouldStop);
      if(shouldStop()) return;
      updateCallback('Saving dictionary...');
      await HiveStorage.putHiveObj('dicts', 'phrase_dict', dict);
      updateCallback('Finished Phrase dictionary (${dict.entryCount} words)');
    }

    if (opts.buildCMUDict) {
      GDict dict = await parser.parseCMUDict(updateCallback, shouldStop);
      if(shouldStop()) return;
      updateCallback('Saving Dict...');
      dict.sortEntries();
      await HiveStorage.putHiveObj('dicts', 'cmu_pron', dict);
      updateCallback('Finished CMU Dict (${dict.entryCount} words)');
    }

    if (opts.buildFinalDict) {
      updateCallback('Building Final dictionary...');

      updateCallback('Loading base dictionaries...');
      // use Wiktionary for definitions
      GDict wDict = await HiveStorage.getHiveObj('dicts', 'wiki_dict');
      GDict pDict = await HiveStorage.getHiveObj('dicts', 'phrase_dict');
      // use Wiktionary common for rarity
      //GDict cDict = await HiveStorage.getHiveObj('dicts', 'wiki_common');



      updateCallback('Organizing senses...');
      for(final entry in wDict.entries) {
        entry.senses = [
          ...entry.senses.where((s) => s.pos == PartOfSpeech.particle),
          ...entry.senses.where((s) => s.pos != PartOfSpeech.particle),
        ];
      }

      //await _applyCMUPronunciation(wDict);
      updateCallback('Appending phrases (${pDict.entryCount})...');
      wDict.append(pDict);

      updateCallback('Applying phrase pronunciations...');
      _applyPhrasePronunciation(wDict);

      updateCallback('Removing entries and senses without IPA...');
      // remove entries without senses or ipa
      wDict = wDict.filter((entry) {
        entry.senses.removeWhere((sense) => sense.ipa.isEmpty);
        if(entry.senses.isEmpty) return false;
        return true;});



      GDict fDict = wDict.clone();

      if(shouldStop()) return;

      updateCallback('Saving Dictionary...');

      fDict.sortEntries();

      await HiveStorage.putHiveObj('dicts', 'final', fDict);
      updateCallback('Finished Final Dict (${fDict.entryCount} words)');
    }

    if (opts.buildRhymeDict) {
      updateCallback('Building Rhyme Dict...');
      GDict fDict = await HiveStorage.getHiveObj('dicts', 'final');
      if(shouldStop()) return;
      RhymeDict rDict = RhymeDict.buildFrom(fDict);
      if(shouldStop()) return;
      updateCallback('Saving Dict...');
      await HiveStorage.putRhymeDict('english', rDict);
      if(shouldStop()) return;
      updateCallback('Finished Rhyme Dict (${rDict.dict.entryCount} words)');
    }

    if(shouldStop()) return;

    if(opts.compactBoxes) {
      updateCallback('Compacting Hive boxes...');
      await HiveStorage.compactBox('rhyme_dicts');
      await HiveStorage.compactBox('dicts');
      updateCallback('Finished compacting boxes.');
    }

    HiveStorage.closeHive();
    updateCallback('_FINISHED_');
    updateCallback('Finished building dictionaries!');
  }

  // apply pronunciations to all phrases
  void _applyPhrasePronunciation(GDict dict)  {
    String phraseIpa = '';
    for (final entry in dict.entries) {
      if(!entry.isPhrase) continue;

      phraseIpa = dict.getPhrase(entry.token).ipas.join(' ');
      if(phraseIpa.split(' ').length != entry.token.split(' ').length) continue;

      if(entry.senses.isEmpty) entry.addSense(DictSense());
      entry.senses[0].ipa = phraseIpa;
      entry.senses[0].pos = PartOfSpeech.phrase;

      // remove other entries... phrases only have one
      //entry.senses.removeRange(1, entry.senses.length);
    }
  }

  Future<void> _applyCMUPronunciation(GDict dict) async {
    // apply cmu pronunciations to wiki
    // use cmu dict as base
    GDict cmuDict = await HiveStorage.getHiveObj('dicts', 'cmu_pron');
    DictEntry tempEntry = DictEntry();
    for (final entry in dict.entries) {
      if (cmuDict.hasEntry(entry.token)) {
        tempEntry = cmuDict.getEntry(entry.token)!;

        for(final cmuSense in tempEntry.senses) {
          for(final wSense in entry.senses) {
            if(IPA.keyEquals(IPA.keyVocals(cmuSense.ipak),
                IPA.keyVocals(wSense.ipak))) {
              wSense.ipak = cmuSense.ipak;
            }
          }
        }
      }
    }
  }

  void stopBuilding() {
    _stopPort?.send('stop');
    _stopPort = null;
  }
}
