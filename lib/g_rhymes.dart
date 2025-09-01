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
import 'package:g_rhymes/providers/rhyme_search_provider.dart';
import 'package:provider/provider.dart';
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
      home: ChangeNotifierProvider(
        create: (_) => RhymeSearchProvider(),
        child: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}


// -----------------------------------------------------------------------------
// Class: MyHomePage
// Description: Home page widget with search functionality, advanced search
//              tab, and display of rhyme results
// -----------------------------------------------------------------------------
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: Column(
        children: [
          AdvancedSearchTab(
            searchParams: context.watch<RhymeSearchProvider>().params, // listens to changes
          ),
          Consumer<RhymeSearchProvider>(
            builder: (context, provider, child) {
              print(provider.rhymes.tokens);
              return Expanded(
                child: provider.searching
                    ? const Center(child: CircularProgressIndicator())
                    : provider.rhymes.isNotEmpty
                    ? GDictListViewer(wordDict: provider.rhymes)
                    : const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
    );
  }
}

