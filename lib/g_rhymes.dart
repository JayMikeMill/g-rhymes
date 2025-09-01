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
 * File: main.dart
 * Description: Entry point for the Flutter app. Sets up global rhyme dictionary,
 *              initializes the app, and displays the home page with search
 *              functionality and advanced search options.
 */

import 'package:flutter/material.dart';
import 'package:g_rhymes/helpers/log.dart';
import 'package:g_rhymes/widgets/advanced_search_tab.dart';
import 'package:g_rhymes/widgets/my_app_bar.dart';
import 'package:g_rhymes/widgets/g_dict_list_viewer.dart';
import 'package:g_rhymes/data/g_dict.dart';
import 'package:g_rhymes/data/rhyme_dict.dart';

// -----------------------------------------------------------------------------
// Main entry point: loads global rhyme dictionary and runs the app
// -----------------------------------------------------------------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the global rhyme dictionary asynchronously
  await Future(() async {
    await loadRhymeDict();
    print(globalRhymeDict.dict.count());
  });

  runApp(const MyApp());
}

// -----------------------------------------------------------------------------
// Class: MyApp
// Description: Root widget of the Flutter application
// -----------------------------------------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

// -----------------------------------------------------------------------------
// Class: MyHomePage
// Description: Home page widget with search functionality, advanced search
//              tab, and display of rhyme results
// -----------------------------------------------------------------------------
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  /// Title displayed in the app bar
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// -----------------------------------------------------------------------------
// Class: _MyHomePageState
// Description: State implementation for MyHomePage, handles searches,
//              async results, and UI updates
// -----------------------------------------------------------------------------
class _MyHomePageState extends State<MyHomePage> {
  String _currentQuery = '';
  RhymeSearchProps _currentSearchProps = RhymeSearchProps();

  GDict? _rhymes;   // Current search results
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _handleSearch(_currentQuery, _currentSearchProps);
  }

  // ---------------------------------------------------------------------------
  /// Handles a search query using the global rhyme dictionary and updates UI
  void _handleSearch(String query, RhymeSearchProps searchProps) async {
    setState(() {
      _currentQuery = query;
      _loading = true;
    });

    // Measure performance for diagnostics
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
      // Custom app bar with search field
      appBar: MyAppBar(
        onSearch: (query) => _handleSearch(query, _currentSearchProps),
      ),

      // Body: advanced search tab + results
      body: Column(
        children: [
          AdvancedSearchTab(
            properties: _currentSearchProps,
            onChanged: (updatedProps) {
              // Update the search properties
              setState(() => _currentSearchProps = updatedProps);

              // Trigger a search with current query and new properties
              _handleSearch(_currentQuery, updatedProps);
            },
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _rhymes != null
                ? GDictListViewer(wordDict: _rhymes!)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
