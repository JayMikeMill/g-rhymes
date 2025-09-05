/*
 * Copyright (c) 2025 GWorks
 *
 * Licensed under the GWorks Non-Commercial License.
 *
 * File: rhyme_list_view.dart
 * Description: Widget that displays a scrollable list of words from a GDict
 *              dictionary. Each word is tappable and opens a dialog showing
 *              detailed word information.
 */

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:g_rhymes/data/g_dict.dart';
import 'package:g_rhymes/data/rhyme_dict.dart';
import 'package:g_rhymes/helpers/log.dart';
import 'package:g_rhymes/widgets/dialogs/dict_entry_dialog.dart';

// -----------------------------------------------------------------------------
// Class: RhymeListView
// Description: Stateful widget rendering a dictionary's words in a scrollable
//              list. Shows a spinner while fetching rhymes.
// -----------------------------------------------------------------------------
class RhymeListView extends StatefulWidget {
  final RhymeSearchParams params;

  const RhymeListView({super.key, required this.params});

  @override
  State<RhymeListView> createState() => _RhymeListViewState();

  /// Font size used for displayed words
  static const fontSize = 26.0;

  /// Text style applied to each word
  static const textStyle = TextStyle(
    fontSize: fontSize,
    color: Colors.blueAccent,
    height: 1.2,
    fontWeight: FontWeight.w500,
  );
}

class _RhymeListViewState extends State<RhymeListView> {
  List<DictEntry> entries = [];
  bool loading = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchRhymes();
  }

  @override
  void didUpdateWidget(RhymeListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fetchRhymes();
  }

  Future<void> _fetchRhymes() async {
    setState(() => loading = true);

    final dict = await Log.timeFunc(
          () async => RhymeDict.getAllRhymes(widget.params),
      "Rhymes",
    );

    setState(() {
      entries = dict.entries;
      loading = false;
    });

    // Scroll to top whenever new list is loaded
    _scrollController.jumpTo(0);
  }

  // ---------------------------------------------------------------------------
  /// Splits entries into chunks of given size
  List<List<DictEntry>> _chunkEntries(int chunkSize) {
    List<List<DictEntry>> chunks = [];
    for (int i = 0; i < entries.length; i += chunkSize) {
      int end = (i + chunkSize < entries.length) ? i + chunkSize : entries.length;
      chunks.add(entries.sublist(i, end));
    }
    return chunks;
  }

  /// Builds a RichText widget for a chunk of entries
  RichText _buildRichTextChunk(BuildContext context, List<DictEntry> chunk) {
    return RichText(
      text: TextSpan(
        children: chunk.map((entry) {
          return TextSpan(
            text: "${entry.token}, ",
            style: RhymeListView.textStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () => showWordDialog(context, entry),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const chunkSize = 100;
    final chunks = _chunkEntries(chunkSize);

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildRichTextChunk(context, chunks[index]),
              childCount: chunks.length,
            ),
          ),
        ),
      ],
    );
  }
}
