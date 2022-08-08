import 'dart:convert';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/models/event_model.dart';
import 'package:bb/widgets/containers/image_container.dart';

// External package
import 'package:json_dynamic_widget/json_dynamic_widget.dart';
import 'package:palette_generator/palette_generator.dart';

class EventPage extends StatefulWidget {
  final EventModel model;
  final bool cache;
  EventPage(this.model, {this.cache = true});
  _EventPageState createState() => new _EventPageState();
}

class _EventPageState extends State<EventPage> {
  Color _dominantColor = Colors.white;

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
        titleSpacing: 15,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
              widget.model.title!
          ),
        ),
      ) : null,
      body: widget.model.sliver == false ? SingleChildScrollView(
        child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
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
            onStretchTrigger: () {
              // Function callback for stretch
              return Future<void>.value();
            },
            expandedHeight: 180.0,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const <StretchMode>[
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
                StretchMode.fadeTitle,
              ],
              centerTitle: true,
              titlePadding: EdgeInsetsDirectional.only(
                start: 45.0,
                end: 10.0,
                bottom: 16.0,
              ),
              title: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.model.getTitle(),
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
            )
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
}