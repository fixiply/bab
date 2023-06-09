import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bab/utils/app_localizations.dart';

// External package
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownDialog extends StatelessWidget {
  final double radius;
  final String filename;

  const MarkdownDialog({Key? key, this.radius = 8, required this.filename}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      child:  Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: Future.delayed(const Duration(milliseconds: 150)).then((value) {
                return rootBundle.loadString('assets/$filename');
              }),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  return Markdown(data: snapshot.data);
                }
                return const Center(child: CircularProgressIndicator());
              },
            )
          ),
          TextButton(
            child: Text(AppLocalizations.of(context)!.text('close')),
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 16),
            ),
            onPressed: () => Navigator.of(context).pop()
          )
        ],
      )
    );
  }
}