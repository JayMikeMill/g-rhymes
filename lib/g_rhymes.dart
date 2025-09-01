import 'package:flutter/material.dart';
import 'package:g_rhymes/helpers/log.dart';
import 'package:g_rhymes/widgets/advanced_search_tab.dart';

import 'package:g_rhymes/widgets/my_app_bar.dart';
import 'package:g_rhymes/widgets/words_list_viewer.dart';

import 'package:g_rhymes/data/g_dict.dart';
import 'package:g_rhymes/data/rhyme_dict.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future(() async {
    await loadRhymeDict();
    print(globalRhymeDict.dict.count());
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _currentQuery = '';
  RhymeSearchProps _currentSearchProps = RhymeSearchProps();

  GDict? _rhymes;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _handleSearch(_currentQuery, _currentSearchProps);
  }

  void _handleSearch(String query, RhymeSearchProps searchProps) async {
    setState(() {
      _currentQuery = query;
      _loading = true;
    });

    // simple async call to avoid blocking UI
    final stopwatch = Stopwatch()..start();
    final rhymes = await Future(() => globalRhymeDict.getRhymes(query, searchProps));
    stopwatch.stop();
    Log.i('getRhymes took: ${stopwatch.elapsedMilliseconds} ms for ${rhymes.count()} words.');

    if (!mounted) return;
    setState(() {
      _rhymes = rhymes;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        onSearch: (query) => _handleSearch(query, _currentSearchProps),
      ),
      body: Column(
        children: [
          AdvancedSearchTab(
            properties: _currentSearchProps,
            onChanged: (updatedProps) {
              // Update the local search props
              setState(() => _currentSearchProps = updatedProps);

              // Trigger a search instantly with current query and new props
              _handleSearch(_currentQuery, updatedProps);
            },
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _rhymes != null
                ? WordsListViewer(wordDict: _rhymes!)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}






