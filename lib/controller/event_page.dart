import 'dart:convert';
import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/basket_page.dart';
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/models/event_model.dart';
import 'package:bab/utils/basket_notifier.dart';
import 'package:bab/widgets/containers/image_container.dart';

// External package
import 'package:badges/badges.dart' as badge;
import 'package:json_dynamic_widget/json_dynamic_widget.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';

class EventPage extends StatefulWidget {
  final EventModel model;
  final bool cache;
  EventPage(this.model, {this.cache = true});

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  final Color _dominantColor = Colors.white;
  int _baskets = 0;

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
            Navigator.pop(context);
          }
        ),
        actions: <Widget> [
          badge.Badge(
            position: badge.BadgePosition.topEnd(top: 0, end: 3),
            badgeAnimation: const badge.BadgeAnimation.slide(
              // animationDuration: const Duration(milliseconds: 300),
            ),
            showBadge: _baskets > 0,
            badgeContent: _baskets > 0 ? Text(
              _baskets.toString(),
              style: const TextStyle(color: Colors.white),
            ) : null,
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return BasketPage();
                }));
              },
            ),
          ),
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
                Navigator.pop(context);
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
            ),
            actions: <Widget> [
              badge.Badge(
                position: badge.BadgePosition.topEnd(top: 0, end: 3),
                badgeAnimation: const badge.BadgeAnimation.slide(
                  // animationDuration: const Duration(milliseconds: 300),
                ),
                showBadge: _baskets > 0,
                badgeContent: _baskets > 0 ? Text(
                  _baskets.toString(),
                  style: const TextStyle(color: Colors.white),
                ) : null,
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return BasketPage();
                    }));
                  },
                ),
              ),
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
    final basketProvider = Provider.of<BasketNotifier>(context, listen: false);
    _baskets = basketProvider.size;
    basketProvider.addListener(() {
      if (!mounted) return;
      setState(() {
        _baskets = basketProvider.size;
      });
    });
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