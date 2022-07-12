import 'dart:convert';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/models/event_model.dart';
import 'package:bb/widgets/containers/image_container.dart';

// External package
// import 'package:dynamic_widget/dynamic_widget.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:carousel_slider/carousel_slider.dart';

class EventPage extends StatefulWidget {
  final EventModel model;
  final bool cache;
  EventPage(this.model, {this.cache = true});
  _EventPageState createState() => new _EventPageState();
}

class _EventPageState extends State<EventPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var registry = JsonWidgetRegistry.instance;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
              pinned: true,
              stretch: true,
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
                      _title()
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    ImageContainer(widget.model.images, emptyImage: Image.asset('assets/images/no_image.png', fit: BoxFit.cover)),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(0.0, 1.5),
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

  String _title() {
    if (widget.model.title != null) {
      return widget.model.title!;
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