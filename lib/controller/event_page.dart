import 'dart:convert';
import 'package:flutter/material.dart';

// Internal package
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/models/event_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/widgets/basket_button.dart';
import 'package:bab/widgets/containers/image_container.dart';

// External package
import 'package:json_dynamic_widget/json_dynamic_widget.dart';
import 'package:palette_generator/palette_generator.dart';

class EventPage extends StatefulWidget {
  final EventModel model;
  final bool cache;
  EventPage(this.model, {this.cache = true});

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  final Color _dominantColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    var registry = JsonWidgetRegistry.instance;
    return Scaffold(
      appBar: widget.model.sliver == false ? AppBar(
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(widget.model.title!),
        ),
        leading: IconButton(
          icon: DeviceHelper.isLargeScreen(context) ? const Icon(Icons.close) : const BackButtonIcon(),
          onPressed:() async {
            Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
          }
        ),
        actions: <Widget> [
          BasketButton()
        ]
      ) : null,
      body: widget.model.sliver == false ? SingleChildScrollView(
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.model.widgets!.length,
          itemBuilder: (BuildContext context, int index) {
            // return Container();
            String data = widget.model.widgets![index];
            return JsonWidgetData.fromDynamic(
              json.decode(data),
              registry: registry,
            )!.build(context: context);
          }
        )
      ) :  CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            foregroundColor: _dominantColor,
            backgroundColor: Theme.of(context).primaryColor,
            leading: IconButton(
              icon: DeviceHelper.isLargeScreen(context) ? const Icon(Icons.close) : const BackButtonIcon(),
              onPressed:() async {
                Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
              }
            ),
            onStretchTrigger: () {
              // Function callback for stretch
              return Future<void>.value();
            },
            expandedHeight: 220.0,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const <StretchMode>[
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
                StretchMode.fadeTitle,
              ],
              centerTitle: true,
              titlePadding: const EdgeInsetsDirectional.only(
                start: 45.0,
                end: 10.0,
                bottom: 16.0,
              ),
              title: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  getTitle(),
                  style: TextStyle(color: _dominantColor),
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  ImageContainer(widget.model.images, emptyImage: Image.asset('assets/images/no_image.png', fit: BoxFit.cover)),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0.0, 2.0),
                        end: Alignment(0.0, 0.0),
                        colors: <Color>[
                          Colors.black54,
                          Color(0x00000000),
                        ],
                        tileMode: TileMode.mirror,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget> [
              BasketButton()
            ]
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
              String data = widget.model.widgets![index];
              return JsonWidgetData.fromDynamic(
                  json.decode(data),
                  registry: registry,
                )!.build(context: context);
              },
              childCount: widget.model.widgets!.length,
            ),
          ),
        ]
      )
    );
  }

  _initialize() async {
    if (widget.model.images!.isNotEmpty) {
      PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(NetworkImage(widget.model.images!.first.url!));
      Color? dominantColor = paletteGenerator.dominantColor!.color;
      // setState(() {
      //   if (dominantColor != null) {
      //     _dominantColor = dominantColor.computeLuminance() < 0.5 ? Colors.white : Colors.black;
      //   }
      // });
    }
  }


  String getTitle() {
    if (widget.model.title != null) {
      return AppLocalizations.of(context)!.localizedText(widget.model.title);
    }
    if (widget.model.top_left != null) {
      return widget.model.top_left!.text!;
    }
    if (widget.model.bottom_left != null) {
      return widget.model.bottom_left!.text!;
    }
    return '';
  }
}