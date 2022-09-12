import 'package:flutter/material.dart';

// Internal package
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';

// External package
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:highlight/languages/dart.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter_highlight/themes/default.dart';

class CodeEditorPage extends StatefulWidget {
  String? initialValue;
  final String? title;
  final String? hintText;
  final int? maxLines;
  CodeEditorPage({this.initialValue, this.title, this.hintText, this.maxLines});

  _CodeEditorPageState createState() => new _CodeEditorPageState();
}

class _CodeEditorPageState extends State<CodeEditorPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late CodeController _textFieldController;

  @override
  void initState() {
    super.initState();
    _textFieldController = CodeController(
      text: widget.initialValue ?? '',
      language: dart,
      theme: defaultTheme,
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
            icon:Icon(Icons.chevron_left),
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
                final value = await _textFieldController.rawText;
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

  _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          duration: Duration(seconds: 10)
      )
    );
  }
}

