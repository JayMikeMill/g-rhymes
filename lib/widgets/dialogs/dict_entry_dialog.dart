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
 * File: dict_entry_dialog.dart
 * Description: Displays a dialog showing detailed information about a
 *              single dictionary entry, including phonetic, rarity, tags,
 *              and definitions.
 */

import 'package:flutter/material.dart';
import 'package:g_rhymes/data/g_dict.dart';

// -----------------------------------------------------------------------------
// Class: DictEntryDialog
// Description: StatelessWidget that displays an AlertDialog with details
//              of a DictEntry.
// -----------------------------------------------------------------------------
class DictEntryDialog extends StatelessWidget {

  /// Dictionary entry to display
  final DictEntry dictEntry;

  /// Constructor
  const DictEntryDialog({super.key, required this.dictEntry});

  // ---------------------------------------------------------------------------
  // Method: build
  // Description: Builds the AlertDialog with title, content fields, and actions.
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // --- Dialog title: word token ---
      title: Text(
        dictEntry.token,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      // --- Dialog content: phonetic, rarity, tag, definition ---
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField('Phonetic', dictEntry.ipas.join(", ")),
            _buildField('Rarity', dictEntry.rarity.token),
            _buildField('Definition', '\n${dictEntry.definitions.join("\n")}'),
          ],
        ),
      ),
      // --- Dialog actions: Close button ---
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Method: _buildField
  // Description: Builds a label/value row for display inside the dialog.
  // ---------------------------------------------------------------------------
  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 16),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Function: showWordDialog
// Description: Convenience function to display the DictEntryDialog for a word.
// -----------------------------------------------------------------------------
void showWordDialog(BuildContext context, DictEntry wordInfo) {
  showDialog(
    context: context,
    builder: (_) => DictEntryDialog(dictEntry: wordInfo),
  );
}
