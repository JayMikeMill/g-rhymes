import 'package:flutter/cupertino.dart';
import 'package:g_rhymes/data/g_dict.dart';
import 'package:g_rhymes/data/rhyme_dict.dart';
import 'package:g_rhymes/helpers/log.dart';

// -----------------------------------------------------------------------------
// Class: CounterModel
// Description: State manager for homepage searches.
// -----------------------------------------------------------------------------
class RhymeSearchProvider extends ChangeNotifier {
  RhymeSearchParams params = RhymeSearchParams();
  GDict rhymes = GDict();
  bool searching = false;

  void setParams(RhymeSearchParams newParams) {
    params = newParams;
    updateResults();
  }

  void setQuery(String query) {
    params.query = query;
    updateResults();
  }

  // ---------------------------------------------------------------------------
  /// Handles a search query using the global rhyme dictionary and updates UI
  void updateResults() async {
    searching  = true;
    notifyListeners();
    rhymes = await Log.timeFunc(() async => globalRhymeDict.getRhymes(params), "Rhymes");
    searching  = false;
    notifyListeners();
  }
}