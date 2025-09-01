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
 * File: g_dict_list_viewer.dart
 * Description: Widget that displays a scrollable list of words from a GDict
 *              dictionary. Each word is tappable and opens a dialog showing
 *              detailed word information.
 */

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:g_rhymes/data/g_dict.dart';
import 'package:g_rhymes/widgets/dialogs/dict_entry_dialog.dart';

// -----------------------------------------------------------------------------
// Class: GDictListViewer
// Description: Stateless widget rendering a dictionary's words in a scrollable
//              list. Tapping a word opens a dialog with its details.
// -----------------------------------------------------------------------------
class GDictListViewer extends StatelessWidget {
  /// Dictionary containing words to display
  final GDict wordDict;

  /// Font size used for displayed words
  static const fontSize = 26.0;

  /// Text style applied to each word
  static const textStyle = TextStyle(
    fontSize: fontSize,
    color: Colors.blueAccent,
    height: 1.2,
    fontWeight: FontWeight.w500,
  );

  // ---------------------------------------------------------------------------
  /// Builds a list of tappable TextSpan widgets for each dictionary entry
  List<TextSpan> _buildTextSpans(BuildContext context) {
    return wordDict.entries.map((entry) => TextSpan(
      text: "${entry.token}, ",
      style: textStyle,
      recognizer: TapGestureRecognizer()
        ..onTap = () => showWordDialog(context, entry),
    )).toList();
  }

  /// Constructor
  const GDictListViewer({super.key, required this.wordDict});

  @override
  Widget build(BuildContext context) {
    final List<TextSpan> textSpans = _buildTextSpans(context);

    // Use CustomScrollView with SliverList for Flutter scroll performance
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(8),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              RichText(text: TextSpan(children: textSpans)),
            ]),
          ),
        ),
      ],
    );
  }
}
