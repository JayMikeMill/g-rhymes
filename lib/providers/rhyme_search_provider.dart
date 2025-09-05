import 'package:flutter/cupertino.dart';
import 'package:g_rhymes/data/g_dict.dart';
import 'package:g_rhymes/data/hive_storage.dart';
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

  void setParams(RhymeSearchParams newParams, {bool search = true}) {
    params = newParams;
    notifyListeners();
  }
}