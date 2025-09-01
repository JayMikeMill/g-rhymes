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
 * File: dict_builder_dialog.dart
 * Description: Displays a dialog to build dictionaries using DictBuilder.
 *              Shows progress in a scrollable, read-only TextField.
 *              Includes Build, Stop, and Close buttons for user interaction.
 */

import 'package:flutter/material.dart';
import '../../dict_builder/dict_builder.dart';

// -----------------------------------------------------------------------------
// Class: DictBuilderDialog
// Description: Wraps a dialog interface for dictionary building.
//              Handles appending text, scrolling, and button actions.
// -----------------------------------------------------------------------------
class DictBuilderDialog {

  /// BuildContext used to display the dialog
  final BuildContext context;

  /// Controller for the multi-line, read-only TextField
  final TextEditingController _controller = TextEditingController();

  /// ScrollController to auto-scroll TextField to bottom
  final ScrollController _scrollController = ScrollController();

  /// Constructor
  DictBuilderDialog(this.context);

  // ---------------------------------------------------------------------------
  // Method: show
  // Description: Displays the dialog asynchronously with buttons and TextField.
  // ---------------------------------------------------------------------------
  Future<void> show() async {
    await showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StatefulBuilder(
            builder: (context, setState) => _buildContent(setState),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Method: _appendText
  // Description: Appends text to the TextField. Handles '/c' command to remove
  //              the last line. Scrolls to bottom after appending.
  // ---------------------------------------------------------------------------
  void _appendText(String text, StateSetter setState) {
    String wholeText = _controller.text;

    // Handle '/c' command: remove last line
    if (text.startsWith('/c')) {
      List<String> lines = wholeText.split('\n');
      if (lines.isNotEmpty) lines.removeLast();
      wholeText = lines.join('\n');
      text = text.replaceFirst('/c', '');
    }

    wholeText += '\n$text';
    _setText(wholeText, setState);
  }

  // ---------------------------------------------------------------------------
  // Method: _setText
  // Description: Sets the TextField text and scrolls to the bottom.
  // ---------------------------------------------------------------------------
  void _setText(String text, StateSetter setState) {
    setState(() {
      _controller.text = text;
    });

    // Scroll to bottom after the frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  // ---------------------------------------------------------------------------
  // Method: _buildContent
  // Description: Constructs the dialog UI: top buttons, read-only TextField,
  //              and Close button.
  // ---------------------------------------------------------------------------
  Widget _buildContent(StateSetter setState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- Top Buttons ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                _setText('', setState); // Clear TextField
                DictBuilder.build((text) { _appendText(text, setState); }); // Start building
              },
              child: const Text("Build Dict"),
            ),
            ElevatedButton(
              onPressed: () {}, // Stop button logic (not implemented)
              child: const Text("Stop"),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // --- Multi-line, read-only TextField showing progress ---
        TextField(
          controller: _controller,
          scrollController: _scrollController,
          maxLines: 8,
          minLines: 6,
          readOnly: true,
          enableInteractiveSelection: false,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        // --- Close Button ---
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ),
      ],
    );
  }
}
