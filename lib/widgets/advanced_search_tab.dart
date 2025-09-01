import 'package:flutter/material.dart';
import 'package:g_rhymes/data/rhyme_search_props.dart';

/// --- Advanced Search Tab Widget ---
class AdvancedSearchTab extends StatefulWidget {
  final RhymeSearchProps properties;
  final ValueChanged<RhymeSearchProps>? onChanged;

  const AdvancedSearchTab({super.key, required this.properties, this.onChanged});

  @override
  State<AdvancedSearchTab> createState() => _AdvancedSearchTabState();
}

class _AdvancedSearchTabState extends State<AdvancedSearchTab> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
            child: expanded ? _buildDropdownGrid() : const SizedBox.shrink(),
          ),
        ),
        const SizedBox(height: 8),
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

  /// --- Dropdown grid: 2x2 layout for Rhymes, Syllables, Speech, Type ---
  Widget _buildDropdownGrid() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDropdownColumn(
              'Rhymes',
              buildEnumDropdown<RhymeType>(
                value: widget.properties.rhymeType,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => widget.properties.rhymeType = val);
                    widget.onChanged?.call(widget.properties);
                  }
                },
                options: RhymeType.values,
              ),
            ),
            const SizedBox(width: 12),
            _buildDropdownColumn(
              'Syllables',
              buildIntDropdown(
                value: widget.properties.syllables,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => widget.properties.syllables = val);
                    widget.onChanged?.call(widget.properties);
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
                value: widget.properties.speechType,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => widget.properties.speechType = val);
                    widget.onChanged?.call(widget.properties);
                  }
                },
                options: SpeechType.values,
              ),
            ),
            const SizedBox(width: 12),
            _buildDropdownColumn(
              'Type',
              buildEnumDropdown<WordType>(
                value: widget.properties.wordType,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => widget.properties.wordType = val);
                    widget.onChanged?.call(widget.properties);
                  }
                },
                options: WordType.values,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// --- Single dropdown column with title on top ---
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
            width: 140, // slightly thinner dropdown
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

  /// --- Generic enum dropdown ---
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
      icon: const SizedBox.shrink(), // remove the arrow
      items: options.map((option) {
        String label = option is RhymeType || option is SpeechType || option is WordType
            ? (option as dynamic).displayName
            : option.toString();
        return DropdownMenuItem<T>(
          value: option,
          child: Center(child: Text(label)),
        );
      }).toList(),
    );
  }

  /// --- Integer dropdown (syllables) ---
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
      icon: const SizedBox.shrink(), // remove arrow
      items: options
          .map((e) => DropdownMenuItem<int>(
        value: e,
        child: Center(child: Text(e == 0 ? 'All' : e.toString())),
      ))
          .toList(),
    );
  }
}
