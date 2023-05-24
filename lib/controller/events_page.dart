import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/basket_page.dart';
import 'package:bb/controller/event_page.dart';
import 'package:bb/controller/forms/form_event_page.dart';
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/models/event_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/basket_notifier.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/widgets/animated_action_button.dart';
import 'package:bb/widgets/builders/full_widget_page.dart';
import 'package:bb/widgets/containers/empty_container.dart';
import 'package:bb/widgets/containers/error_container.dart';
import 'package:bb/widgets/containers/image_container.dart';
import 'package:bb/widgets/containers/shimmer_container.dart';
import 'package:bb/widgets/custom_drawer.dart';
import 'package:bb/widgets/custom_menu_button.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';
import 'package:bb/widgets/search_text.dart';

// External package
import 'package:badges/badges.dart' as badge;
import 'package:provider/provider.dart';

class EventsPage extends StatefulWidget {
  EventsPage({Key? key}) : super(key: key);

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> with AutomaticKeepAliveClientMixin<EventsPage> {
  late ScrollController? _controller;
  final TextEditingController _searchQueryController = TextEditingController();
  Future<List<EventModel>>? _events;
  int _baskets = 0;

  // Edition mode
  bool _remove = false;
  bool _hidden = false;
  bool _archived = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: SearchText(
          _searchQueryController,
          () {  _fetch(); }
        ),
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        actions: <Widget> [
          badge.Badge(
            position: badge.BadgePosition.topEnd(top: 0, end: 3),
            animationDuration: const Duration(milliseconds: 300),
            animationType: badge.BadgeAnimationType.slide,
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
          CustomMenuButton(
            context: context,
            publish: currentUser != null && currentUser!.isAdmin(),
            filtered: currentUser != null && currentUser!.isAdmin(),
            archived: _archived,
            onSelected: (value) async {
              if (value == 1) {
                await Database().publishAll();
              } else if (value == Menu.hidden) {
                bool checked = !_remove;
                if (checked) {
                  _hidden = false;
                }
                setState(() { _remove = checked; });
                _fetch();
              }
            },
          )
        ]
      ),
      drawer: !DeviceHelper.isDesktop && currentUser != null ? CustomDrawer(context) : null,
      body: RefreshIndicator(
        onRefresh: () => _fetch(),
        child: FutureBuilder<List<EventModel>>(
          future: _events,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                if (_searchQueryController.text.isNotEmpty) {
                  return EmptyContainer(message: AppLocalizations.of(context)!.text('no_result'));
                }
                return EmptyContainer(message: AppLocalizations.of(context)!.text('no_event'));
              }
              if (DeviceHelper.isDesktop || DeviceHelper.isTablette(context)) {
                return GridView.builder(
                  controller: _controller,
                  padding: const EdgeInsets.all(4),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: MediaQuery.of(context).size.width / (DeviceHelper.isLargeScreen(context) ? 3 : 2),
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0
                  ),
                  // physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    EventModel event = snapshot.data![index];
                    return _item(event, true);
                  }
                );
              }
              return ListView.builder(
                controller: _controller,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  EventModel event = snapshot.data![index];
                  return _item(event, false);
                }
              );
            }
            if (snapshot.hasError) {
              return ErrorContainer(snapshot.error.toString());
            }
            return ShimmerContainer();
          }
        )
      ),
      floatingActionButton: Visibility(
        visible: currentUser != null && currentUser!.isAdmin(),
        child: AnimatedActionButton(
          title: AppLocalizations.of(context)!.text('new'),
          icon: const Icon(Icons.add),
          onPressed: _new,
        )
      )
    );
  }

  Widget _item(EventModel model, bool grid) {
    return Padding(
      padding: grid ? const EdgeInsets.all(6.0) : const EdgeInsets.symmetric(vertical: 6.0, horizontal: 15.0),
      child: Card(
        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
        elevation: 1.0,
        child: InkWell(
          onTap: () async {
            if (model.page != null && model.page!.isNotEmpty) {
              var data = JsonWidgetData.fromDynamic(model.page!);
              if (data != null) {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (BuildContext context) =>
                    FullWidgetPage(data: data),
                  ),
                );
              }
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return EventPage(model);
              }));
            }
          },
          onLongPress: currentUser != null && (currentUser!.isAdmin() || model.creator == currentUser!.uuid) ? () {
            _edit(model);
          } : null,
          child: _event(model, grid),
        ),
      ),
    );
  }

  Widget _event(EventModel model, bool grid) {
    if (!grid && model.axis == Axis.horizontal) {
      return Stack(
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 180,
                width: MediaQuery.of(context).size.width / 2.5,
                child: ImageContainer(
                  model.getImages(),
                  fit: BoxFit.cover,
                  color: Colors.transparent,
                  cache: currentUser != null && currentUser!.isAdmin() == false,
                  emptyImage: Image.asset('assets/images/no_image.png')
                )
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          model.title!,
                          overflow: grid ? TextOverflow.ellipsis : null,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      )
                    ),
                    if (model.subtitle != null) Container(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                      child: Text(
                        model.subtitle ?? '',
                        overflow: grid ? TextOverflow.ellipsis : null,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.left,
                      )
                    )
                  ],
                )
              )
            ],
          ),
          if (currentUser != null && currentUser!.isAdmin()) Positioned(
            top: 4.0,
            right: 4.0,
            child: _indicator(model),
          )
        ],
      );
    }
    return Stack(
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              fit: DeviceHelper.isDesktop ? FlexFit.tight: FlexFit.loose,
              child: SizedBox(
                width: double.infinity,
                child: ImageContainer(
                  model.getImages(),
                  fit: BoxFit.cover,
                  cache: currentUser != null && currentUser!.isAdmin() == false,
                  emptyImage: Image.asset('assets/images/no_image.png', fit: BoxFit.scaleDown)
                )
              ),
            ),
            if(model.title != null && model.title!.isNotEmpty) Container(
              padding: const EdgeInsets.all(5),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  model.title!,
                  overflow: grid ? TextOverflow.ellipsis : null,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.left,
                ),
              )
            ),
            if(model.subtitle != null && model.subtitle!.isNotEmpty) Container(
              padding: const EdgeInsets.all(5),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  model.subtitle ?? '',
                  overflow: grid ? TextOverflow.ellipsis : null,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.left,
                ),
              )
            )
          ],
        ),
        if (currentUser != null && currentUser!.isAdmin()) Positioned(
          top: 4.0,
          right: 4.0,
          child: _indicator(model),
        )
      ],
    );
  }

  Widget _indicator(EventModel model) {
    bool visible = false;
    Icon? icon;
    Color color = Theme.of(context).primaryColor;
    String message = '';
    if (model.status == Status.disabled) {
      visible = true;
      icon = const Icon(Icons.delete, color: Colors.white);
      color = PointerColor;
      message = AppLocalizations.of(context)!.text('archive');
    } else if (model.status == Status.pending) {
      visible = true;
      icon = const Icon(Icons.hourglass_empty, color: Colors.white);
      message = AppLocalizations.of(context)!.text('pending');
    }
    return Visibility(
      visible: visible,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: color
        ),
        child: Tooltip(
          message: message,
          child: icon,
        ),
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
    _fetch();
  }

  _fetch() async {
    setState(() {
      _events = Database().getEvents(
        searchText: _searchQueryController.value.text,
        status: currentUser != null && currentUser!.isAdmin() ?  _archived ? Status.disabled : Status.publied : null,
      );
    });
  }

  _new() async {
    EventModel newModel = EventModel();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormEventPage(newModel);
    })).then((value) {
      _fetch();
    });
  }

  _edit(EventModel model) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormEventPage(model);
    })).then((value) { _fetch(); });
  }
}

