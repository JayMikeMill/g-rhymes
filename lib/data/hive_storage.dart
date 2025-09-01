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
 * File: hive_storage.dart
 * Description: Provides a Flutter-compatible Hive storage interface for
 *              GDict and RhymeDict objects. Handles initialization,
 *              adapter registration, box opening, and basic CRUD operations.
 *              Supports loading Hive boxes from assets for Web, Android, and iOS.
 *
 * Build adapters with: dart run build_runner build --delete-conflicting-outputs
 */

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'g_dict.dart';
import 'rhyme_dict.dart';

// -----------------------------------------------------------------------------
// Class: HiveStorage
// Description: Provides a Flutter-compatible Hive storage interface for
//              GDict and RhymeDict objects. Handles initialization,
//              adapter registration, box opening, and basic CRUD operations.
// -----------------------------------------------------------------------------


class HiveStorage {
  /// Tracks whether Hive has been initialized
  static bool _hiveInitialized = false;

  /// Base path for Hive boxes
  static final String _boxPath = path.join(Directory.current.path, 'assets/');

  /// Hive box name for storing RhymeDict objects
  static const boxRhymeDicts = 'rhyme_dicts';

  // ---------------------------------------------------------------------------
  // Private Methods
  // ---------------------------------------------------------------------------

  /// Initializes Hive and registers all required adapters
  static Future<void> _initializeHive() async {
    if (_hiveInitialized) return;

    await Hive.close();
    Hive.init(_boxPath);
    _registerAdapters();
    _hiveInitialized = true;
  }

  /// Registers Hive adapters for all custom types if not already registered
  static void _registerAdapters() {
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

  /// Opens a Hive box, loading from assets if required (Web, Android, iOS)
  static Future<Box> _openBox(String hiveBox) async {
    if (!_hiveInitialized) await _initializeHive();

    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      final bytes = await rootBundle.load('assets/$hiveBox.hive');
      final list = bytes.buffer.asUint8List();
      return await Hive.openBox(hiveBox, bytes: list);
    }

    return await Hive.openBox(hiveBox);
  }

  // ---------------------------------------------------------------------------
  // Public CRUD Methods
  // ---------------------------------------------------------------------------

  /// Stores an object in a given Hive box under the specified key
  static Future<void> putHiveObj(String hiveBox, String boxKey, dynamic obj) async {
    Box box = await _openBox(hiveBox);
    await box.put(boxKey, obj);
    await box.close();
  }

  /// Retrieves an object from a Hive box by key
  static dynamic getHiveObj(String hiveBox, String boxKey) async {
    Box box = await _openBox(hiveBox);
    dynamic obj = box.get(boxKey, defaultValue: null);
    await box.close();
    return obj;
  }

  /// Compacts a Hive box to reclaim storage
  static Future<void> compactBox(String hiveBox) async {
    Box box = await _openBox(hiveBox);
    await box.compact();
  }

  // ---------------------------------------------------------------------------
  // RhymeDict Convenience Methods
  // ---------------------------------------------------------------------------

  /// Stores a RhymeDict object in the default RhymeDict Hive box
  static Future<void> putRhymeDict(String boxKey, RhymeDict dict) async =>
      await putHiveObj(boxRhymeDicts, boxKey, dict);

  /// Retrieves a RhymeDict object by key from the default Hive box
  /// Returns an empty RhymeDict if none exists
  static Future<RhymeDict> getRhymeDict(String boxKey) async =>
      (await getHiveObj(boxRhymeDicts, boxKey) ?? RhymeDict(GDict())) as RhymeDict;
}
