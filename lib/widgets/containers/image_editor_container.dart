import 'dart:io';
import 'dart:typed_data';
import 'package:bb/utils/constants.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/utils/app_localizations.dart';

// External package
import 'package:image_picker/image_picker.dart';
import 'package:stack_board/stack_board.dart';

class ImageEditorContainer extends StatefulWidget {
  final String assetName;

  ImageEditorContainer(this.assetName);
  @override
  _ImageEditorContainerState createState() => _ImageEditorContainerState();
}

class BackgroundGridPaint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final height = size.height;
    final width = size.width;
    final paint = Paint();

    Path mainBackground = Path();
    mainBackground.addRect(Rect.fromLTRB(0, 0, width, height));
    paint.color = Colors.black26;

    final heightLine = height ~/ 20; // your Horizontal line
    final widthLine = (width ~/ 20); // your Vertical line

    for(int i = 1 ; i < height ; i++){
      if(i % heightLine == 0){
        Path linePath = Path();
        linePath.addRect(Rect.fromLTRB(0, i.toDouble(), width, (i+2).toDouble()));
        canvas.drawPath(linePath, paint);
      }
    }
    for(int i = 1 ; i < width ; i++){
      if(i % widthLine == 0){
        Path linePath = Path();
        linePath.addRect(Rect.fromLTRB(i.toDouble(), 0 , (i+2).toDouble(), height));
        canvas.drawPath(linePath, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}

class _ImageEditorContainerState extends State<ImageEditorContainer> {
  late StackBoardController _boardController;

  @override
  void initState() {
    super.initState();
    _boardController = StackBoardController();
  }

  @override
  void dispose() {
    _boardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton.icon(
                  icon: Icon(Icons.text_fields_outlined),
                  label: Text(AppLocalizations.of(context)!.text('text')),
                  style: TextButton.styleFrom(
                    primary: Colors.black,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                  onPressed: () async {
                    _boardController.add(
                      const AdaptiveText(
                        'Un simple texte',
                        tapToEdit: true,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton.icon(
                  icon: Icon(Icons.image),
                  label: Text(AppLocalizations.of(context)!.text('image')),
                  style: TextButton.styleFrom(
                    primary: Colors.black,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                  onPressed: () async {
                    final ImagePicker _picker = ImagePicker();
                    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 640, imageQuality: 80);
                    if (image != null) {
                      Uint8List bytes =  await image.readAsBytes();
                      _boardController.add(
                        StackBoardItem(
                          child: Image.memory(bytes),
                        ),
                      );
                    }
                  }
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton.icon(
                  icon: Icon(Icons.palette),
                  label: Text(AppLocalizations.of(context)!.text('drawing')),
                  style: TextButton.styleFrom(
                    primary: Colors.black,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                  onPressed: () async {
                    _boardController.add(
                      const StackDrawing(
                        caseStyle: CaseStyle(
                          borderColor: Colors.grey,
                          iconColor: Colors.white,
                          boxAspectRatio: 1,
                        ),
                      ),
                    );
                  }
                ),
              ),
            ],
          ),
          Container(
            color: FillColor,
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Image( image: AssetImage(widget.assetName))
                ),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    debugPrint('height: ${constraints.maxHeight} width: ${constraints.maxWidth}');
                    return Container(
                      height: constraints.maxWidth,
                      width: constraints.maxWidth,
                      child: StackBoard(
                        controller: _boardController,
                      )
                    );
                  }
                )
              ]
            )
          ),
        ]
      ),
    );
  }
}

