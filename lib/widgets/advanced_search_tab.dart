/*
 * Copyright (c) 2025 GWorks
 *
 * Licensed under the GWorks Non-Commercial License.
 *
 * File: advanced_search_tab.dart
 * Description: Flutter widget providing a compact advanced search panel for rhyme
 *              searches. Includes a single horizontal scrollable row for
 *              Rhymes, Syllables, Speech, and Word Type.
 */

import 'package:flutter/material.dart';
import 'package:g_rhymes/data/rhyme_dict.dart';
import 'package:g_rhymes/widgets/scrollable_row_with_arrows.dart';

class AdvancedSearchTab extends StatefulWidget {
  final RhymeSearchParams searchParams;
  final Function(RhymeSearchParams) onChanged;

  const AdvancedSearchTab({
    super.key,
    required this.searchParams,
    required this.onChanged,
  });

  @override
  State<AdvancedSearchTab> createState() => _AdvancedSearchTabState();
}

class _AdvancedSearchTabState extends State<AdvancedSearchTab> {
  bool expanded = false;

  /// Tracks whether the children should be actually removed after collapse
  bool _hideChildren = false;

  /// Estimate or compute the full height of the dropdown row
  double get _fullHeight => 101; // adjust to actual content height if needed

  /// Duration of the collapse/expand animation
  static const _animationDuration = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Animated container for expansion
        // Replace your TweenAnimationBuilder block with this
        Container(
         // width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1), // bottom border stays
              top: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1), // bottom border stays
            ),
          ),
          child: ClipRect(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: expanded ? 1 : 0, end: expanded ? 1 : 0),
              duration: _animationDuration,
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return SizedBox(
                  height: value * _fullHeight,
                  child: child,
                );
              },
              child:  SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child:  _buildDropdownRow(context),
              )
            ),
          ),
        ),
        // Toggle button
        Row(
          children: [
            // Search button (left)
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                onPressed: () {
                  widget.onChanged(widget.searchParams);
                },
                child: const Text(
                  'Search',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(width: 0), // no gap for segmented look

            // Advanced button (right)
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                ),
                onPressed: () {
                  if (expanded) {
                    // collapse
                    setState(() => expanded = false);
                    Future.delayed(_animationDuration, () {
                      if (!mounted) return;
                      setState(() => _hideChildren = true);
                    });
                  } else {
                    // expand
                    setState(() {
                      _hideChildren = false;
                      expanded = true;
                    });
                  }
                },
                child: Text(
                  expanded ? 'Hide Options' : 'Show Options',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),

      ],
    );
  }

  static const double _dropdownHPadding = 8;
  /// Builds a single horizontal scrollable row with all four dropdowns
  Widget _buildDropdownRow(BuildContext context) {

    return ScrollableRowWithArrows(
      padding: EdgeInsets.all(12),
      children: [
        _buildDropdownColumn(
          'Rhymes',
          buildEnumDropdown<RhymeType>(
            value: widget.searchParams.rhymeType,
            onChanged: (val) {
              if (val != null) {
                setState(() => widget.searchParams.rhymeType = val);
                widget.onChanged(widget.searchParams);
              }
            },
            options: RhymeType.values,
          ),
        ),
        const SizedBox(width: _dropdownHPadding),
        _buildDropdownColumn(
          'Syllables',
          buildIntDropdown(
            value: widget.searchParams.syllables,
            onChanged: (val) {
              if (val != null) {
                setState(() => widget.searchParams.syllables = val);
                widget.onChanged(widget.searchParams);
              }
            },
            options: [0, 1, 2, 3, 4, 5],
          ),
        ),
        const SizedBox(width: _dropdownHPadding),
        _buildDropdownColumn(
          'Speech',
          buildEnumDropdown<SpeechType>(
            value: widget.searchParams.speechType,
            onChanged: (val) {
              if (val != null) {
                setState(() => widget.searchParams.speechType = val);
                widget.onChanged(widget.searchParams);
              }
            },
            options: SpeechType.values,
          ),
        ),
        const SizedBox(width: _dropdownHPadding),
        _buildDropdownColumn(
          'Type',
          buildEnumDropdown<EntryType>(
            value: widget.searchParams.wordType,
            onChanged: (val) {
              if (val != null) {
                setState(() => widget.searchParams.wordType = val);
                widget.onChanged(widget.searchParams);
              }
            },
            options: EntryType.values,
          ),
        ),
      ],
    );
  }

  /// Builds a single dropdown column with a title
  Widget _buildDropdownColumn(String title, Widget dropdown) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 120, // narrower to fit horizontal row
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
    );
  }

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
      icon: const SizedBox.shrink(),
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
