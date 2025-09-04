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
import 'dart:io';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

import 'package:g_rhymes/providers/rhyme_search_provider.dart';
import 'package:g_rhymes/widgets/advanced_search_tab.dart';
import 'package:g_rhymes/widgets/my_app_bar.dart';
import 'package:g_rhymes/widgets/g_dict_list_viewer.dart';


// -----------------------------------------------------------------------------
// Main entry point: loads global rhyme dictionary and runs the app
// -----------------------------------------------------------------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) setWindowSize();

  // Load the global rhyme dictionary asynchronously
  await Future(() async {
    await loadRhymeDict();
  });

  runApp(const MyApp());
}

Screen? screen;

Future<void> setWindowSize() async {
  const double width = 800;
  const double height = 900;

  // Set the window size
  setWindowMinSize(const Size(width, height));
  setWindowMaxSize(const Size(width, height));

  // Get screen info to center the window
  screen ??= await getCurrentScreen();

  if (screen != null) {
    final screenFrame = screen!.frame;
    final left = screenFrame.left + (screenFrame.width - width) / 2;
    final top = screenFrame.top + (screenFrame.height - height) / 2;
    setWindowFrame(Rect.fromLTWH(left, top, width, height));
  }
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
      appBar: MyAppBar(
        onChanged: (s) {context.read<RhymeSearchProvider>().setQuery(s, search: false);},
        onSearch: () {context.read<RhymeSearchProvider>().updateResults();},
      ),
      body: Column(
        children: [
          AdvancedSearchTab(
            searchParams: context.watch<RhymeSearchProvider>().params, // listens to changes
            onChanged: (s) {context.read<RhymeSearchProvider>().setParams(s);},
          ),
          Consumer<RhymeSearchProvider>(
            builder: (context, provider, child) {
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

