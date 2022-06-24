import 'package:flutter/material.dart';

// Internal package
import 'package:bb/utils/app_localizations.dart';

// External package
import 'package:extended_image/extended_image.dart';

class ImageEditorPage extends StatefulWidget {
  final String url;
  final Rect? rect;
  ImageEditorPage(this.url, this.rect);
  @override
  _ImageEditorPageState createState() => _ImageEditorPageState();
}

class _ImageEditorPageState extends State<ImageEditorPage> {
  EditorCropLayerPainter? _cropLayerPainter;
  final _editorKey = GlobalKey<ExtendedImageEditorState>();

  double _aspectRatio = CropAspectRatios.ratio16_9;
  final List<AspectRatioItem> _aspectRatios = <AspectRatioItem>[
    AspectRatioItem(text: 'custom', value: CropAspectRatios.custom),
    AspectRatioItem(text: 'original', value: CropAspectRatios.original),
    AspectRatioItem(text: '1*1', value: CropAspectRatios.ratio1_1),
    AspectRatioItem(text: '4*3', value: CropAspectRatios.ratio4_3),
    AspectRatioItem(text: '3*4', value: CropAspectRatios.ratio3_4),
    AspectRatioItem(text: '16*9', value: CropAspectRatios.ratio16_9),
    AspectRatioItem(text: '9*16', value: CropAspectRatios.ratio9_16)
  ];

  @override
  void initState() {
    _cropLayerPainter = const EditorCropLayerPainter();
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
            PopupMenuButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.aspect_ratio),
              tooltip: AppLocalizations.of(context)!.text('crop'),
              onSelected: (AspectRatioItem item) async {
                setState(() {
                  _aspectRatio = item.value!;
                });
              },
              itemBuilder: (BuildContext context) {
                List<PopupMenuEntry<AspectRatioItem>> items = <PopupMenuEntry<AspectRatioItem>>[];
                for(AspectRatioItem ratio in _aspectRatios) {
                  items.add(PopupMenuItem(
                    value: ratio,
                    child: Text(ratio.text)
                  ));
                }
                return items;
              }
            ),
            IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.refresh),
              tooltip: AppLocalizations.of(context)!.text('reset'),
              onPressed: () async {
                _aspectRatio = CropAspectRatios.ratio16_9;
                _editorKey.currentState?.reset();
              }
            ),
          ]
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ExtendedImage.network(widget.url,
              fit: BoxFit.contain,
              mode: ExtendedImageMode.editor,
              extendedImageEditorKey: _editorKey,
              initEditorConfigHandler: (ExtendedImageState? state) {
                return EditorConfig(
                  maxScale: 8.0,
                  cropRectPadding: EdgeInsets.all(20.0),
                  hitTestSize: 20.0,
                  cropLayerPainter: _cropLayerPainter!,
                  initCropRectType: InitCropRectType.imageRect,
                  cropAspectRatio:  _aspectRatio
                );
              },
            )
          )
        ]
      ),
    );
  }
}

class AspectRatioItem {
  AspectRatioItem({required this.value, required this.text});
  final String text;
  final double? value;
}

