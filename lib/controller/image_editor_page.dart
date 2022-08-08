import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/utils/app_localizations.dart';

// External package
import 'package:extended_image/extended_image.dart';

class ImageEditorPage extends StatefulWidget {
  final String assetName;

  ImageEditorPage(this.assetName);
  @override
  _ImageEditorPageState createState() => _ImageEditorPageState();
}

class _ImageEditorPageState extends State<ImageEditorPage> {
  final _editorKey = GlobalKey<ExtendedImageEditorState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Text(AppLocalizations.of(context)!.text('image_editor')),
        iconTheme: new IconThemeData(color: Theme.of(context).primaryColor),
        titleTextStyle: Theme.of(context).textTheme.headline6,
        backgroundColor: Colors.transparent,
        bottomOpacity: 0.0,
        elevation: 0.0,
        leading: IconButton(
            icon:Icon(Icons.chevron_left),
            onPressed:() async {
              Navigator.pop(context, false);
            }
        ),
        actions: <Widget> [
          IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.save),
            tooltip: AppLocalizations.of(context)!.text('save'),
            onPressed: () async {
              Navigator.pop(context, _editorKey.currentState!.getCropRect());
            }
          ),
          IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.refresh),
            tooltip: AppLocalizations.of(context)!.text('reset'),
            onPressed: () async {
              _editorKey.currentState?.reset();
            }
          ),
        ]
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ExtendedImage(
              image: ExtendedExactAssetImageProvider(
                widget.assetName,
                cacheRawData: true,
              ),
              height: 400,
              width: 400,
              extendedImageEditorKey: _editorKey,
              mode: ExtendedImageMode.editor,
              fit: BoxFit.contain,
              initEditorConfigHandler: (_) => EditorConfig(
                maxScale: 8.0,
                cropRectPadding: const EdgeInsets.all(20.0),
                hitTestSize: 20.0,
                cropAspectRatio: 2 / 1,
              ),
            )
          )
        ]
      ),
    );
  }
}

