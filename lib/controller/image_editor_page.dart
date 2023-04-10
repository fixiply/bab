import 'package:flutter/material.dart';

// Internal package
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/utils/constants.dart';

// External package
import 'package:extended_image/extended_image.dart';
import 'package:flutter_painter/flutter_painter_pure.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ImageEditorPage extends StatefulWidget {
  final String assetName;

  ImageEditorPage(this.assetName);
  @override
  _ImageEditorPageState createState() => _ImageEditorPageState();
}

class _ImageEditorPageState extends State<ImageEditorPage> {
  ObjectDrawable? selectedObjectDrawable;
  FocusNode textFocusNode = FocusNode();
  late PainterController controller;
  final _editorKey = GlobalKey<ExtendedImageEditorState>();
  Paint shapePaint = Paint()
    ..strokeWidth = 5
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  @override
  void initState() {
    super.initState();
    controller = PainterController(
      settings: PainterSettings(
        text: TextSettings(
          focusNode: textFocusNode,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
        ),
        freeStyle: const FreeStyleSettings(
          color: Colors.black,
          strokeWidth: 5,
        ),
        shape: ShapeSettings(
          paint: shapePaint,
        ),
        scale: const ScaleSettings(
          enabled: true,
          minScale: 1,
          maxScale: 5,
        )
      )
    );
    textFocusNode.addListener(onFocus);
    // Initialize background
    initBackground();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Text(AppLocalizations.of(context)!.text('personalization')),
        foregroundColor: Theme.of(context).primaryColor,
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
            icon: const Icon(Icons.more_vert),
            tooltip: AppLocalizations.of(context)!.text('menu'),
            onPressed: () async {
              _editorKey.currentState?.reset();
            }
          ),
        ]
      ),
      body: Wrap(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Free-style eraser
              IconButton(
                icon: Icon(
                  PhosphorIcons.regular.trash
                ),
                onPressed: controller.selectedObjectDrawable == null ? null : removeSelectedDrawable,
              ),
              // Free-style drawing
              IconButton(
                icon: Icon(
                    PhosphorIcons.regular.cameraRotate
                ),
                onPressed: controller.selectedObjectDrawable != null && controller.selectedObjectDrawable is ImageDrawable ? flipSelectedImageDrawable : null,
              ),
              // Add text
              IconButton(
                icon: Icon(
                  PhosphorIcons.regular.arrowClockwise,
                ),
                onPressed: controller.canRedo ? redo : null,
              ),
              // Add sticker image
              IconButton(
                icon: Icon(
                  PhosphorIcons.regular.arrowCounterClockwise,
                ),
                onPressed: controller.canUndo ? undo : null,
              ),
            ],
          ),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Container(
                color: FillColor,
                padding: EdgeInsets.all(12),
                height: constraints.maxWidth - 30,
                child: FlutterPainter(
                  controller: controller,
                  onSelectedObjectDrawableChanged: (value) {
                    setState(() {
                      selectedObjectDrawable = value;
                    });
                  }
                ),
              );
            }
          ),
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, _, __) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: const BoxDecoration(
                      borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                      color: Colors.white54,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selectedObjectDrawable is FreeStyleDrawable || controller.freeStyleMode != FreeStyleMode.none) ...[
                          Text(AppLocalizations.of(context)!.text('free_style_settings')),
                          Row(
                            children: [
                              Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.text('thickness'))),
                              Expanded(
                                flex: 3,
                                child: Slider.adaptive(
                                  min: 2,
                                  max: 25,
                                  value: controller.freeStyleStrokeWidth,
                                  onChanged: (value) {
                                    controller.freeStyleStrokeWidth = value;
                                  },
                                  onChangeEnd: (value) {
                                    if (selectedObjectDrawable is FreeStyleDrawable) {
                                      controller.replaceDrawable(selectedObjectDrawable!, (selectedObjectDrawable as FreeStyleDrawable).copyWith(strokeWidth: value));
                                    }
                                  }
                                ),
                              ),
                            ],
                          ),
                          if (controller.freeStyleMode == FreeStyleMode.draw)
                            Row(
                              children: [
                                Expanded( flex: 1, child: Text(AppLocalizations.of(context)!.text('color'))),
                                // Control free style color hue
                                Expanded(
                                  flex: 3,
                                  child: Slider.adaptive(
                                    min: 0,
                                    max: 359.99,
                                    value: HSVColor.fromColor(controller.freeStyleColor).hue,
                                    activeColor:
                                    controller.freeStyleColor,
                                    onChanged: (value) {
                                      controller.freeStyleColor = HSVColor.fromAHSV(1, value, 1, 1).toColor();
                                    },
                                    onChangeEnd: (value) {
                                      if (selectedObjectDrawable is FreeStyleDrawable) {
                                        controller.replaceDrawable(selectedObjectDrawable!, (selectedObjectDrawable as FreeStyleDrawable).copyWith(
                                            color: HSVColor.fromAHSV(1, value, 1, 1).toColor()
                                        ));                                      }
                                    }
                                  ),
                                ),
                              ],
                            ),
                        ],
                        if (selectedObjectDrawable is TextDrawable || textFocusNode.hasFocus) ...[
                          Text(AppLocalizations.of(context)!.text('text_settings')),
                          Row(
                            children: [
                              Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.text('font_size'))),
                              Expanded(
                                flex: 3,
                                child: Slider.adaptive(
                                  min: 8,
                                  max: 96,
                                  value:
                                  controller.textStyle.fontSize ?? 14,
                                  onChanged: (value) {
                                    setState(() {
                                      controller.textSettings = controller.textSettings.copyWith(
                                          textStyle: controller.textSettings.textStyle.copyWith(fontSize: value));
                                    });
                                  },
                                  onChangeEnd: (value) {
                                    if (selectedObjectDrawable is TextDrawable) {
                                      controller.replaceDrawable(selectedObjectDrawable!, (selectedObjectDrawable as TextDrawable).copyWith(
                                          style: (selectedObjectDrawable as TextDrawable).style.copyWith(fontSize: value))
                                      );
                                    }
                                  }
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.text('color'))),
                              Expanded(
                                flex: 3,
                                child: Slider.adaptive(
                                  min: 0,
                                  max: 359.99,
                                  value: HSVColor.fromColor(controller.textStyle.color ?? Colors.black) .hue,
                                  activeColor: controller.textStyle.color,
                                  onChanged: (value) {
                                    controller.textStyle = controller.textStyle.copyWith(color: HSVColor.fromAHSV(1, value, 1, 1).toColor());
                                  },
                                  onChangeEnd: (value) {
                                    if (selectedObjectDrawable is TextDrawable) {
                                      controller.replaceDrawable(selectedObjectDrawable!, (selectedObjectDrawable as TextDrawable).copyWith(
                                          style: (selectedObjectDrawable as TextDrawable).style.copyWith(color: HSVColor.fromAHSV(1, value, 1, 1).toColor()))
                                      );
                                    }
                                  }
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (selectedObjectDrawable is ShapeDrawable || controller.shapeFactory != null) ...[
                          Text(AppLocalizations.of(context)!.text('shape_settings')),
                          Row(
                            children: [
                              Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.text('thickness'))),
                              Expanded(
                                flex: 3,
                                child: Slider.adaptive(
                                  min: 2,
                                  max: 25,
                                  value: controller.shapePaint?.strokeWidth ?? shapePaint.strokeWidth,
                                  onChanged: (value) {
                                    setShapeFactoryPaint((controller.shapePaint ?? shapePaint).copyWith(strokeWidth: value));
                                  },
                                  onChangeEnd: (value) {
                                    if (selectedObjectDrawable is ShapeDrawable) {
                                      controller.replaceDrawable(selectedObjectDrawable!, (selectedObjectDrawable as ShapeDrawable).copyWith(
                                          paint: (selectedObjectDrawable as ShapeDrawable).paint.copyWith(strokeWidth: value))
                                      );
                                    }
                                  }
                                ),
                              ),
                            ],
                          ),
                          // Control shape color hue
                          Row(
                            children: [
                              Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.text('color'))),
                              Expanded(
                                flex: 3,
                                child: Slider.adaptive(
                                  min: 0,
                                  max: 359.99,
                                  value: HSVColor.fromColor((controller.shapePaint ?? shapePaint).color).hue,
                                  activeColor: (controller.shapePaint ?? shapePaint) .color,
                                  onChanged: (value) {
                                    setShapeFactoryPaint(
                                        (controller.shapePaint ?? shapePaint).copyWith(
                                          color: HSVColor.fromAHSV(1, value, 1, 1).toColor(),
                                        )
                                    );
                                  },
                                  onChangeEnd: (value) {
                                    if (selectedObjectDrawable is ShapeDrawable) {
                                      controller.replaceDrawable(selectedObjectDrawable!, (selectedObjectDrawable as ShapeDrawable).copyWith(
                                          paint: (selectedObjectDrawable as ShapeDrawable).paint.copyWith(color: HSVColor.fromAHSV(1, value, 1, 1).toColor()))
                                      );                                      }
                                  }
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.text('fill_shape'))),
                              Expanded(
                                flex: 3,
                                child: Center(
                                  child: Switch(
                                    value: (controller.shapePaint ?? shapePaint).style == PaintingStyle.fill,
                                    onChanged: (value) {
                                      setShapeFactoryPaint(
                                          (controller.shapePaint ?? shapePaint).copyWith(
                                            style: value ? PaintingStyle.fill : PaintingStyle.stroke,
                                          )
                                      );
                                    }
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]
      ),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, _, __) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Free-style eraser
            IconButton(
              icon: Icon(
                PhosphorIcons.regular.eraser,
                color: controller.freeStyleMode == FreeStyleMode.erase ? Theme.of(context).colorScheme.secondary : null,
              ),
              onPressed: toggleFreeStyleErase,
            ),
            // Free-style drawing
            IconButton(
              icon: Icon(
                PhosphorIcons.regular.scribbleLoop,
                color: controller.freeStyleMode == FreeStyleMode.draw ? Theme.of(context).colorScheme.secondary : null,
              ),
              onPressed: toggleFreeStyleDraw,
            ),
            // Add text
            IconButton(
              icon: Icon(
                PhosphorIcons.regular.textT,
                color: textFocusNode.hasFocus ? Theme.of(context).colorScheme.secondary : null,
              ),
              onPressed: addText,
            ),
            // Add sticker image
            IconButton(
              icon: Icon(
                PhosphorIcons.regular.sticker,
              ),
              onPressed: addSticker,
            ),
            // Add shapes
            if (controller.shapeFactory == null)
              PopupMenuButton<ShapeFactory?>(
                tooltip: "Add shape",
                itemBuilder: (context) => <ShapeFactory, String>{
                  LineFactory(): "Line",
                  ArrowFactory(): "Arrow",
                  DoubleArrowFactory(): "Double Arrow",
                  RectangleFactory(): "Rectangle",
                  OvalFactory(): "Oval",
                }
                .entries.map((e) => PopupMenuItem(
                  value: e.key,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        getShapeIcon(e.key),
                        color: Colors.black,
                      ),
                      Text(" ${e.value}")
                    ],
                  )))
                .toList(),
                onSelected: selectShape,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    getShapeIcon(controller.shapeFactory),
                    color: controller.shapeFactory != null ? Theme.of(context).colorScheme.secondary : null,
                  ),
                ),
              )
            else
              IconButton(
                icon: Icon(
                  getShapeIcon(controller.shapeFactory),
                  color: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: () => selectShape(null),
              ),
          ],
        ),
      )
    );
  }

  void initBackground() async {
    // Extension getter (.image) to get [ui.Image] from [ImageProvider]
    final image = await AssetImage(widget.assetName).image;
    setState(() {
      controller.background = image.backgroundDrawable;
    });
  }

  void onFocus() {
    setState(() {});
  }

  bool landscapeOrientation() {
    if (DeviceHelper.isDesktop) {
      return true;
    }
    return DeviceHelper.landscapeOrientation(context);
  }

  static IconData getShapeIcon(ShapeFactory? shapeFactory) {
    if (shapeFactory is LineFactory) return PhosphorIcons.regular.lineSegment;
    if (shapeFactory is ArrowFactory) return PhosphorIcons.regular.arrowUpRight;
    if (shapeFactory is DoubleArrowFactory) {
      return PhosphorIcons.regular.arrowsHorizontal;
    }
    if (shapeFactory is RectangleFactory) return PhosphorIcons.regular.rectangle;
    if (shapeFactory is OvalFactory) return PhosphorIcons.regular.circle;
    return PhosphorIcons.regular.polygon;
  }

  void undo() {
    controller.undo();
  }

  void redo() {
    controller.redo();
  }

  void toggleFreeStyleDraw() {
    controller.freeStyleMode = controller.freeStyleMode != FreeStyleMode.draw
        ? FreeStyleMode.draw
        : FreeStyleMode.none;
  }

  void toggleFreeStyleErase() {
    controller.freeStyleMode = controller.freeStyleMode != FreeStyleMode.erase
        ? FreeStyleMode.erase
        : FreeStyleMode.none;
    // showModalStyleErase();
  }

  void addText() {
    if (controller.freeStyleMode != FreeStyleMode.none) {
      controller.freeStyleMode = FreeStyleMode.none;
    }
    controller.addText();
  }

  void addSticker() async {
    // final imageLink = await showDialog<String>(
    //     context: context,
    //     builder: (context) => const SelectStickerImageDialog(
    //       imagesLinks: imageLinks,
    //     ));
    // if (imageLink == null) return;
    // controller.addImage(await NetworkImage(imageLink).image, const Size(100, 100));
  }

  void setShapeFactoryPaint(Paint paint) {
    // Set state is just to update the current UI, the [FlutterPainter] UI updates without it
    setState(() {
      controller.shapePaint = paint;
    });
  }

  void selectShape(ShapeFactory? factory) {
    controller.shapeFactory = factory;
  }

  void removeSelectedDrawable() {
    final selectedDrawable = controller.selectedObjectDrawable;
    if (selectedDrawable != null) controller.removeDrawable(selectedDrawable);
  }

  void flipSelectedImageDrawable() {
    final imageDrawable = controller.selectedObjectDrawable;
    if (imageDrawable is! ImageDrawable) return;

    controller.replaceDrawable(imageDrawable, imageDrawable.copyWith(flipped: !imageDrawable.flipped));
  }
}

