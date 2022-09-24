import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as Foundation;

// Internal package
import 'package:bb/controller/basket_page.dart';
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/models/event_model.dart';
import 'package:bb/utils/basket_notifier.dart';
import 'package:bb/widgets/containers/image_container.dart';

// External package
import 'package:badges/badges.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';

class EventPage extends StatefulWidget {
  final EventModel model;
  final bool cache;
  EventPage(this.model, {this.cache = true});
  _EventPageState createState() => new _EventPageState();
}

class _EventPageState extends State<EventPage> {
  Color _dominantColor = Colors.white;
  int _baskets = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    double? widthFactor = _widthFactor();
    if (widthFactor != null) {
      return FractionallySizedBox(
        widthFactor: _widthFactor(),
        alignment: Alignment.topCenter,
        child: _body()
      );
    }
    return _body();
  }

  Widget _body() {
    var registry = JsonWidgetRegistry.instance;
    return Scaffold(
      appBar: widget.model.sliver == false ? AppBar(
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
              widget.model.title!
          ),
        ),
        actions: <Widget> [
          Badge(
            position: BadgePosition.topEnd(top: 0, end: 3),
            animationDuration: Duration(milliseconds: 300),
            animationType: BadgeAnimationType.slide,
            showBadge: _baskets > 0,
            badgeContent: _baskets > 0 ? Text(
              _baskets.toString(),
              style: TextStyle(color: Colors.white),
            ) : null,
            child: IconButton(
              icon: Icon(Icons.shopping_cart_outlined),
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
            expandedHeight: 220.0,
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
            ),
            actions: <Widget> [
              Badge(
                position: BadgePosition.topEnd(top: 0, end: 3),
                animationDuration: Duration(milliseconds: 300),
                animationType: BadgeAnimationType.slide,
                showBadge: _baskets > 0,
                badgeContent: _baskets > 0 ? Text(
                  _baskets.toString(),
                  style: TextStyle(color: Colors.white),
                ) : null,
                child: IconButton(
                  icon: Icon(Icons.shopping_cart_outlined),
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

  double? _widthFactor() {
    if (Foundation.kIsWeb) {
      return 0.6;
    }
    if (!DeviceHelper.mobileLayout(context) && DeviceHelper.landscapeOrientation(context)) {
      return 0.6;
    }
    return null;
  }
}