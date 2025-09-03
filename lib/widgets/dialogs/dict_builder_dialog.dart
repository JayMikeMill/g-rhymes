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

  final DictBuilder builder = DictBuilder();

  /// Options for dictionary building
  final DictBuildOptions options = DictBuildOptions();

  // ---------------------------------------------------------------------------
  // Method: show
  // Description: Displays the dialog asynchronously with buttons and TextField.
  // ---------------------------------------------------------------------------
  Future<void> show() async {
    await showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: StatefulBuilder(
              builder: (context, setState) => _buildContent(setState),
            ),
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
  void _appendLine(String line, StateSetter setState) {
    String wholeText = _controller.text;

    if (line.startsWith('/c')) {
      List<String> lines = wholeText.split('\n');
      if (lines.isNotEmpty) lines.removeLast();
      wholeText = lines.join('\n');
      line = line.replaceFirst('/c', '\n');
    }

    wholeText += '$line';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  // ---------------------------------------------------------------------------
  // Method: _buildContent
  // Description: Constructs the dialog UI: title, options, TextField, and buttons.
  // ---------------------------------------------------------------------------
  Widget _buildContent(StateSetter setState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- Title ---
        const Text(
          'Dictionary Builder',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // --- Boolean Options as compact Chips ---
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            _buildChip('Wiktionary', options.buildWikitionary, (val) {
              setState(() => options.buildWikitionary = val);
            }),
            _buildChip('Wiki Common', options.buildWikiCommon, (val) {
              setState(() => options.buildWikiCommon = val);
            }),
            _buildChip('CMU Dict', options.buildCMUDict, (val) {
              setState(() => options.buildCMUDict = val);
            }),
            _buildChip('Final Dict', options.buildFinalDict, (val) {
              setState(() => options.buildFinalDict = val);
            }),
            _buildChip('Rhyme Dict', options.buildRhymeDict, (val) {
              setState(() => options.buildRhymeDict = val);
            }),
          ],
        ),
        const SizedBox(height: 8),

        // --- Compact Number Selector ---
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Status Interval:'),
            const SizedBox(width: 4),
            SizedBox(
              width: 70,
              child: DropdownButton<int>(
                isDense: true,
                value: options.statusInterval,
                items: [1000, 2000, 5000, 10000, 15000]
                    .map((val) => DropdownMenuItem(
                  value: val,
                  child: Text('$val', style: const TextStyle(fontSize: 12)),
                ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => options.statusInterval = val);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // --- TextField for progress (DOS/code style) ---
        Container(
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade700),
          ),
          padding: const EdgeInsets.all(4),
          child: TextField(
            controller: _controller,
            scrollController: _scrollController,
            maxLines: 8,
            minLines: 4,
            readOnly: true,
            enableInteractiveSelection: false,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Colors.greenAccent,
            ),
            decoration: null,
            textAlignVertical: TextAlignVertical.top,
          ),
        ),
        const SizedBox(height: 12),

        // --- Buttons at bottom (stay inside dialog) ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _setText('', setState);
                  builder.build(options, (text) => _appendLine(text, setState));
                },
                child: const Text("Build"),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: ElevatedButton(
                onPressed: () => builder.stopBuilding(),
                child: const Text("Stop"),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  builder.stopBuilding();
                  Navigator.pop(context);
                },
                child: const Text("Close"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Helper: Build a FilterChip ---
  Widget _buildChip(String label, bool value, ValueChanged<bool> onSelected) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: value,
      onSelected: onSelected,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
