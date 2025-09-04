import 'package:flutter/cupertino.dart';
import 'package:g_rhymes/data/g_dict.dart';
import 'package:g_rhymes/data/hive_storage.dart';
import 'package:g_rhymes/data/rhyme_dict.dart';
import 'package:g_rhymes/helpers/log.dart';

// -----------------------------------------------------------------------------
// Global instance of RhymeDict
// -----------------------------------------------------------------------------

/// Holds the currently loaded rhyming dictionary for quick access
RhymeDict rhymeDict = RhymeDict();

/// Loads the rhyming dictionary from Hive storage
Future<void> loadRhymeDict() async {
  Log.i('Loading Rhyming dictionary...');
  rhymeDict = await HiveStorage.getRhymeDict('english');
  Log.i('Rhyme Dict Loaded (${rhymeDict.dict.entryCount} words)');
}

// -----------------------------------------------------------------------------
// Class: CounterModel
// Description: State manager for homepage searches.
// -----------------------------------------------------------------------------
class RhymeSearchProvider extends ChangeNotifier {
  RhymeSearchParams params = RhymeSearchParams();
  GDict rhymes = GDict();
  bool searching = false;

  void setParams(RhymeSearchParams newParams, {bool search = true}) {
    params = newParams;
    if(search) updateResults();
  }

  void setQuery(String query, {bool search = true}) {
    params.query = query;
    if(search) updateResults();
  }

  // ---------------------------------------------------------------------------
  /// Handles a search query using the global rhyme dictionary and updates UI
  void updateResults() async {
    searching  = true;
    notifyListeners();
    rhymes = await Log.timeFunc(() async => rhymeDict.getRhymes(params), "Rhymes");
    searching  = false;
    notifyListeners();
  }
}