import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:g_rhymes/data/g_dict.dart';
import 'package:g_rhymes/widgets/dialogs/dict_entry_dialog.dart';

class WordsListViewer extends StatelessWidget {
  final GDict wordDict;

  static const fontSize = 26.0;

  static const textStyle = TextStyle(
    fontSize: fontSize,
    color: Colors.blueAccent,
    height: 1.2,
    fontWeight: FontWeight.w500,
  );

  List<TextSpan> _buildTextSpans(BuildContext context) {
    return wordDict.entries.map((entry) => TextSpan(
      text: "${entry.token}, ",
      style: textStyle,
      recognizer: TapGestureRecognizer()
        ..onTap = () => showWordDialog(context, entry),
    )).toList();
  }

  const WordsListViewer({super.key, required this.wordDict});

  @override
  Widget build(BuildContext context) {
    final List<TextSpan> textSpans = _buildTextSpans(context);

    // Wrap in a sliver to keep Flutter's scroll optimizations
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(8),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              RichText(text: TextSpan(children: textSpans)),
            ]),
          ),
        ),
      ],
    );
  }
}
