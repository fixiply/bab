import 'package:flutter/material.dart';

// Internal package
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';

// External package
import 'package:highlight/languages/dart.dart';
import 'package:code_text_field/code_text_field.dart';

class CodeEditorPage extends StatefulWidget {
  final String? initialValue;
  final String? title;
  final String? hintText;
  final int? maxLines;
  const CodeEditorPage({super.key, this.initialValue, this.title, this.hintText, this.maxLines});

  @override
  _CodeEditorPageState createState() => _CodeEditorPageState();
}

class _CodeEditorPageState extends State<CodeEditorPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late CodeController _textFieldController;

  @override
  void initState() {
    super.initState();
    _textFieldController = CodeController(
      text: widget.initialValue ?? '',
      language: dart
    );
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: FillColor,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.text('code_editor')),
          elevation: 0,
          foregroundColor: Theme.of(context).primaryColor,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed:() async {
              Navigator.pop(context, false);
            }
          ),
          actions: <Widget> [
            IconButton(
              padding: EdgeInsets.zero,
              tooltip: AppLocalizations.of(context)!.text('save'),
              icon: const Icon(Icons.save),
              onPressed: () async {
                final value = _textFieldController.value.text;
                Navigator.pop(context, value);
              }
            ),
            IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.clear),
              onPressed: () async {
                _textFieldController.clear();
              }
            ),
          ]
        ),
        body: SingleChildScrollView(
          child: CodeField(
            controller: _textFieldController,
          )
        )
    );
  }
}

