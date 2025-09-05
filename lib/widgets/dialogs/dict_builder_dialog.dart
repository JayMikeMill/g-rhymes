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

import 'dart:ui';

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
        backgroundColor: const Color(0xFFC0C0C0), // classic gray
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // square corners
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFC0C0C0), // gray fill
            border: Border(
              top: const BorderSide(color: Colors.white, width: 2),   // highlight top/left
              left: const BorderSide(color: Colors.white, width: 2),
              right: const BorderSide(color: Colors.black, width: 2), // shadow right/bottom
              bottom: const BorderSide(color: Colors.black, width: 2),
            ),
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
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
      line = line.replaceFirst('/c', '');
    }

    if(wholeText.isNotEmpty) wholeText += '\n';
    wholeText += line;

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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- Title Bar ---
        Container(
          color: const Color(0xFF000080), // classic blue
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: const Center(
            child: Text(
              'Dictionary Builder',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        // --- Padded Content Column ---
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Boolean Options as Win98 toggle buttons ---
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    _buildWin98Chip('Wiktionary', options.buildWikitionary, (val) {
                      setState(() => options.buildWikitionary = val);
                    }),
                    _buildWin98Chip('Wiki Common', options.buildWikiCommon, (val) {
                      setState(() => options.buildWikiCommon = val);
                    }),
                    _buildWin98Chip('Phrase Dict', options.buildPhraseDict, (val) {
                      setState(() => options.buildPhraseDict = val);
                    }),
                    _buildWin98Chip('CMU Dict', options.buildCMUDict, (val) {
                      setState(() => options.buildCMUDict = val);
                    }),
                    _buildWin98Chip('Final Dict', options.buildFinalDict, (val) {
                      setState(() => options.buildFinalDict = val);
                    }),
                    _buildWin98Chip('Rhyme Dict', options.buildRhymeDict, (val) {
                      setState(() => options.buildRhymeDict = val);
                    }),
                    _buildWin98Chip('Compact', options.compactBoxes, (val) {
                      setState(() => options.compactBoxes = val);
                    }),
                  ],
                ),

                const SizedBox(height: 12),

                // --- Expanded TextField ---
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.zero,
                      border: const Border(
                        top: BorderSide(color: Colors.black, width: 2),
                        left: BorderSide(color: Colors.black, width: 2),
                        right: BorderSide(color: Colors.white, width: 2),
                        bottom: BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: TextField(
                      controller: _controller,
                      scrollController: _scrollController,
                      maxLines: null,
                      expands: true,
                      readOnly: true,
                      enableInteractiveSelection: false,
                      style: const TextStyle(
                        fontFamily: 'Consolas',
                        fontSize: 16,
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: null,
                      textAlignVertical: TextAlignVertical.top,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // --- Win98 Buttons at bottom ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Win98Button(
                        label: 'Build',
                        onPressed: () {
                          _setText('', setState);
                          builder.build(options, (text) => _appendLine(text, setState));
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Win98Button(
                        label: 'Stop',
                        onPressed: builder.stopBuilding,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Win98Button(
                        label: 'Close',
                        onPressed: () {
                          builder.stopBuilding();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  // --- Helper: Build a FilterChip ---
  Widget _buildWin98Chip(String label, bool value, ValueChanged<bool> onSelected) {
    return GestureDetector(
      onTap: () => onSelected(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          border: Border(
            top: BorderSide(color: value ? Colors.black : Colors.white, width: 2),
            left: BorderSide(color: value ? Colors.black : Colors.white, width: 2),
            right: BorderSide(color: value ? Colors.white : Colors.black, width: 2),
            bottom: BorderSide(color: value ? Colors.white : Colors.black, width: 2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value)
              const Icon(
                Icons.check,
                size: 14,
                color: Colors.black,
              ),
            if (value)
              const SizedBox(width: 4), // spacing between check and text
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Win98Button extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const Win98Button({required this.label, required this.onPressed, Key? key}) : super(key: key);

  @override
  State<Win98Button> createState() => _Win98ButtonState();
}

class _Win98ButtonState extends State<Win98Button> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          border: Border(
            top: BorderSide(color: _isPressed ? Colors.black : Colors.white, width: 2),
            left: BorderSide(color: _isPressed ? Colors.black : Colors.white, width: 2),
            bottom: BorderSide(color: _isPressed ? Colors.white : Colors.black, width: 2),
            right: BorderSide(color: _isPressed ? Colors.white : Colors.black, width: 2),
          ),
        ),
        child: Text(
          widget.label,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black
          ),
        ),
      ),
    );
  }
}
