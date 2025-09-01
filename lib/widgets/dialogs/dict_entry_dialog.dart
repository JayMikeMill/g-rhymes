import 'package:flutter/material.dart';
import 'package:g_rhymes/data/g_dict.dart';

class DictEntryDialog extends StatelessWidget {
  final DictEntry dictEntry;
  const DictEntryDialog({super.key, required this.dictEntry});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        dictEntry.token,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField('Phonetic', dictEntry.ipas.join(", ")),
            _buildField('Rarity', dictEntry.rarity.token),
            _buildField('Tag', dictEntry.tags.join(", ")),
            _buildField('Definition', dictEntry.meanings.join("\n")),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

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

// Usage example:
void showWordDialog(BuildContext context, DictEntry wordInfo) {
  showDialog(
    context: context,
    builder: (_) => DictEntryDialog(dictEntry: wordInfo),
  );
}
