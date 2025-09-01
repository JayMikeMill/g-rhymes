import 'package:flutter/material.dart';
import '../../dict_builder/dict_builder.dart';

class DictBuilderDialog {
  final BuildContext context;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  DictBuilderDialog(this.context);

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

  void _setText(String text, StateSetter setState) {
    setState(() {
      _controller.text = text;
    });

    // Scroll to bottom after the frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  Widget _buildContent(StateSetter setState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                _setText('', setState);
                DictBuilder.build((text) {_appendText(text, setState);});
              },
              child: const Text("Build Dict"),
            ),
            ElevatedButton(
              onPressed: () {}, // Stop button logic
              child: const Text("Stop"),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Multiline, read-only TextField
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

        // Close button
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
