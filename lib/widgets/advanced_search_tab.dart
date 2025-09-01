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
 * File: advanced_search_tab.dart
 * Description: Flutter widget providing an advanced search panel for rhyme
 *              searches. Includes dropdowns for Rhymes, Syllables, Speech, and
 *              Word Type. Notifies parent widget on changes via callback.
 */

import 'package:flutter/material.dart';
import 'package:g_rhymes/data/rhyme_dict.dart';
import 'package:g_rhymes/g_rhymes.dart';
import 'package:g_rhymes/providers/rhyme_search_provider.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

// -----------------------------------------------------------------------------
// Class: AdvancedSearchTab
// Description: Stateful widget for the advanced search panel. Wraps search
//              properties and exposes a callback when any property changes.
// -----------------------------------------------------------------------------
class AdvancedSearchTab extends StatefulWidget {
  /// Current search properties
  final RhymeSearchParams searchParams;

  const AdvancedSearchTab({super.key, required this.searchParams});

  @override
  State<AdvancedSearchTab> createState() => _AdvancedSearchTabState();
}

// -----------------------------------------------------------------------------
// Class: _AdvancedSearchTabState
// Description: Internal state for AdvancedSearchTab. Handles expansion/collapse
//              and renders the dropdown grid.
// -----------------------------------------------------------------------------
class _AdvancedSearchTabState extends State<AdvancedSearchTab> {
  /// Whether the advanced panel is expanded
  bool expanded = false;

  void onChanged(BuildContext context) {
    context.read<RhymeSearchProvider>().setParams(widget.searchParams);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Animated container for expanding/collapsing dropdown grid
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: expanded ? _buildDropdownGrid(context) : const SizedBox.shrink(),
          ),
        ),
        const SizedBox(height: 8),
        // Button to toggle expansion
        GestureDetector(
          onTap: () => setState(() => expanded = !expanded),
          child: Container(
            width: 180,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              expanded ? 'Hide Advanced' : 'Show Advanced',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  /// Builds the 2x2 grid of dropdowns for Rhymes, Syllables, Speech, and Type
  Widget _buildDropdownGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDropdownColumn(
              'Rhymes',
              buildEnumDropdown<RhymeType>(
                value: widget.searchParams.rhymeType,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => widget.searchParams.rhymeType = val);
                    onChanged(context);
                  }
                },
                options: RhymeType.values,
              ),
            ),
            const SizedBox(width: 12),
            _buildDropdownColumn(
              'Syllables',
              buildIntDropdown(
                value: widget.searchParams.syllables,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => widget.searchParams.syllables = val);
                    onChanged(context);
                  }
                },
                options: [0, 1, 2, 3, 4, 5],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDropdownColumn(
              'Speech',
              buildEnumDropdown<SpeechType>(
                value: widget.searchParams.speechType,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => widget.searchParams.speechType = val);
                    onChanged(context);
                  }
                },
                options: SpeechType.values,
              ),
            ),
            const SizedBox(width: 12),
            _buildDropdownColumn(
              'Type',
              buildEnumDropdown<EntryType>(
                value: widget.searchParams.wordType,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => widget.searchParams.wordType = val);
                    onChanged(context);
                  }
                },
                options: EntryType.values,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  /// Helper to build a single dropdown column with a title
  Widget _buildDropdownColumn(String title, Widget dropdown) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 140, // slightly narrower dropdown
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(6),
              ),
              child: dropdown,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  /// Builds a generic enum dropdown
  Widget buildEnumDropdown<T>({
    required T value,
    required ValueChanged<T?> onChanged,
    required List<T> options,
  }) {
    return DropdownButton<T>(
      value: value,
      isExpanded: true,
      onChanged: onChanged,
      underline: const SizedBox.shrink(),
      style: const TextStyle(fontSize: 14, color: Colors.black),
      alignment: Alignment.center,
      icon: const SizedBox.shrink(), // remove default arrow
      items: options.map((option) {
        String label = option is RhymeType || option is SpeechType || option is EntryType
            ? (option as dynamic).displayName
            : option.toString();
        return DropdownMenuItem<T>(
          value: option,
          child: Center(child: Text(label)),
        );
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  /// Builds an integer dropdown (for syllables)
  Widget buildIntDropdown({
    required int value,
    required ValueChanged<int?> onChanged,
    required List<int> options,
  }) {
    return DropdownButton<int>(
      value: value,
      isExpanded: true,
      onChanged: onChanged,
      underline: const SizedBox.shrink(),
      style: const TextStyle(fontSize: 14, color: Colors.black),
      alignment: Alignment.center,
      icon: const SizedBox.shrink(),
      items: options
          .map((e) => DropdownMenuItem<int>(
        value: e,
        child: Center(child: Text(e == 0 ? 'All' : e.toString())),
      ))
          .toList(),
    );
  }
}
