import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:g_rhymes/data/g_dict.dart';
import 'package:g_rhymes/data/rhyme_dict.dart';
import 'package:g_rhymes/data/hive_storage.dart';
import 'package:g_rhymes/dict_builder/dict_parser.dart';

class DictBuilder {
  static int maxWords          = -1;
  static int statusInterval    = 5000;

  static bool buildWikitionary = true;
  static bool buildWikiCommon  = true;
  static bool buildCMUDict     = true;
  static bool buildFinalDict   = true;
  static bool buildRhymeDict   = true;

  static void _setParserOptions() {
    DictParser.maxWords          = maxWords;
    DictParser.statusInterval    = statusInterval;
  }

  static void build(Function(String) updateCallback) async {
    _setParserOptions();

    final receivePort = ReceivePort();

    // Listen for updates from the isolate
    receivePort.listen((message) {
      if (message is String) { updateCallback(message); }
    });

    // Start the isolate
    await Isolate.spawn(_buildDictionaries, [receivePort.sendPort]);
  }

  static void _buildDictionaries(List<dynamic> args) async {
    final SendPort sendPort = args[0];
    final updateCallback = sendPort.send;

    updateCallback('Started building dictionaries...');

    if(buildWikitionary) {
      GDict dict = await DictParser.parseWiktionary(updateCallback);
      updateCallback('Sorting and saving dictionary...');
      dict.sortWordsByName();
      HiveStorage.putHiveObj('dicts', 'wiki_dict', dict);
      updateCallback('Finished building Wiktionary.');
    }

    if(buildWikiCommon) {
      GDict dict = await DictParser.parseWikiCommon(updateCallback);
      updateCallback('Sorting and saving dictionary...');
      dict.sortWordsByName();
      HiveStorage.putHiveObj('dicts', 'wiki_common', dict);
      updateCallback('Finished building Wiki common words.');
    }

    if(buildCMUDict) {
      GDict dict = await DictParser.parseCMUDict(updateCallback);
      updateCallback('Sorting and saving dictionary...');
      dict.sortWordsByName();
      HiveStorage.putHiveObj('dicts', 'cmu_pron', dict);
      updateCallback('Finished building CMU pronunciation dict '
          '${dict.count()} words)');
    }

    if(buildFinalDict) {
      sendPort.send('Building final dictionary...');
      GDict wDict = await HiveStorage.getHiveObj('dicts', 'wiki_dict');
      GDict cDict = await HiveStorage.getHiveObj('dicts', 'wiki_common');
      GDict filteredDict = wDict.filteredBy(cDict);

      GDict cmuDict = await HiveStorage.getHiveObj('dicts', 'cmu_pron');

      for(DictEntry word in filteredDict.entries) {
        if(cmuDict.hasEntry(word.token)) {
          //word.ipa = cmuDict.getWordByName(word.name)!.ipa;
        }
      }

      updateCallback('Sorting and saving dictionary...');
      cDict.sortWordsByName();
      HiveStorage.putHiveObj('dicts', 'final', filteredDict);
      updateCallback('Finished building final dict (${filteredDict.count()} words)');
    }

    if(buildRhymeDict) {
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
