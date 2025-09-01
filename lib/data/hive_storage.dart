import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'g_dict.dart';
import 'rhyme_dict.dart';


// dart run build_runner build --delete-conflicting-outputs

class HiveStorage {
  static bool _hiveInitialized = false;

  static final String _boxPath =
  path.join(Directory.current.path, 'assets/');

  static const boxRhymeDicts = 'rhyme_dicts';

  /// Initialize Hive (Flutter-compatible)
  static Future<void> _initializeHive() async {
    if (_hiveInitialized) return;

    await Hive.close();
    Hive.init(_boxPath);
    _registerAdapters();
    _hiveInitialized = true;
  }

  static void _registerAdapters() {
    // Only register if not already registered
    
    if (!Hive.isAdapterRegistered(RarityAdapter().typeId)) {
      Hive.registerAdapter<Rarity>(RarityAdapter());
    }
    if (!Hive.isAdapterRegistered(PartOfSpeechAdapter().typeId)) {
      Hive.registerAdapter<PartOfSpeech>(PartOfSpeechAdapter());
    }
    if (!Hive.isAdapterRegistered(SenseTagAdapter().typeId)) {
      Hive.registerAdapter<SenseTag>(SenseTagAdapter());
    }
    if (!Hive.isAdapterRegistered(DictSenseAdapter().typeId)) {
    Hive.registerAdapter<DictSense>(DictSenseAdapter());
    }
    if (!Hive.isAdapterRegistered(DictEntryAdapter().typeId)) {
      Hive.registerAdapter<DictEntry>(DictEntryAdapter());
    }
    if (!Hive.isAdapterRegistered(GDictAdapter().typeId)) {
      Hive.registerAdapter<GDict>(GDictAdapter());
    }
    if (!Hive.isAdapterRegistered(RhymeDictAdapter().typeId)) {
      Hive.registerAdapter<RhymeDict>(RhymeDictAdapter());
    }
  }

  static Future<Box> _openBox(String hiveBox) async {
    if(!_hiveInitialized) await _initializeHive();

    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      // Load the Hive file as bytes from assets
      final bytes = await rootBundle.load('assets/$hiveBox.hive');
      final list = bytes.buffer.asUint8List();
      return await Hive.openBox(hiveBox, bytes: list);
    }

    return await Hive.openBox(hiveBox);
  }

  static Future<void> putHiveObj(
      String hiveBox, String boxKey, dynamic obj) async {
    Box box = await _openBox(hiveBox);
    await box.put(boxKey, obj);
    await box.close();
  }

  static dynamic getHiveObj(String hiveBox, String boxKey) async {
    Box box = await _openBox(hiveBox);
    dynamic obj = box.get(boxKey, defaultValue: null);
    await box.close();
    return obj;

  }

  static Future<void> compactBox(String hiveBox) async {
    Box box = await _openBox(hiveBox);
    await box.compact();
  }

  static Future<void> putRhymeDict(String boxKey, RhymeDict dict) async =>
      await putHiveObj(boxRhymeDicts, boxKey, dict);
  static Future<RhymeDict> getRhymeDict(String boxKey) async =>
      (await getHiveObj(boxRhymeDicts, boxKey) ?? RhymeDict(GDict())) as RhymeDict;
}
