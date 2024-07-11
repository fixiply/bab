import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as Foundation;

// Internal package
import 'package:bab/controller/event_page.dart';
import 'package:bab/controller/forms/form_event_page.dart';
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/models/event_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/widgets/animated_action_button.dart';
import 'package:bab/widgets/basket_button.dart';
import 'package:bab/widgets/builders/full_widget_page.dart';
import 'package:bab/widgets/containers/empty_container.dart';
import 'package:bab/widgets/containers/error_container.dart';
import 'package:bab/widgets/containers/image_container.dart';
import 'package:bab/widgets/containers/shimmer_container.dart';
import 'package:bab/widgets/custom_drawer.dart';
import 'package:bab/widgets/custom_menu_anchor.dart';
import 'package:bab/widgets/search_text.dart';

// External package
import 'package:json_dynamic_widget/json_dynamic_widget.dart';

class EventsPage extends StatefulWidget {
  String? country;
  EventsPage({Key? key, this.country}) : super(key: key);

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> with AutomaticKeepAliveClientMixin<EventsPage> {
  late ScrollController? _controller;
  final TextEditingController _searchQueryController = TextEditingController();
  Future<List<EventModel>>? _events;

  // Edition mode
  Status? _status;

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
    super.build(context);
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
          BasketButton(),
          CustomMenuAnchor(
            showFilters: currentUser != null && currentUser!.isAdmin(),
            status: _status,
            onSelected: (value) async {
              if (value == Menu.archived) {
                setState(() { _status = (_status == Status.archived ? null : Status.archived ); });
                _fetch();
              } else if (value == Menu.pending) {
                setState(() { _status = (_status == Status.pending ? null : Status.pending ); });
                _fetch();
              }
            },
          )
        ]
      ),
      drawer: !DeviceHelper.isLargeScreen && currentUser != null ? CustomDrawer(context) : null,
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
              if (_isGrid()) {
                return GridView.builder(
                  controller: _controller,
                  padding: const EdgeInsets.all(4),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: MediaQuery.of(context).size.width / getDeviceAxisCount(),
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

  bool _isGrid() {
    if (Foundation.kIsWeb) {
      return true;
    }
    if (DeviceHelper.isMobile) {
      return DeviceHelper.landscapeOrientation(context);
    }
    return DeviceHelper.isDesktop || DeviceHelper.isTablet;
  }

  int getDeviceAxisCount() {
    if (DeviceHelper.isDesktop) {
      return 3;
    }
    if (DeviceHelper.isMobile) {
      return 2;
    }
    return DeviceHelper.landscapeOrientation(context) ? 3 : 2;
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
                          AppLocalizations.of(context)!.localizedText(model.title),
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
                        AppLocalizations.of(context)!.localizedText(model.subtitle),
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
            if(model.title != null) Container(
              padding: const EdgeInsets.all(5),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)!.localizedText(model.title),
                  overflow: grid ? TextOverflow.ellipsis : null,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.left,
                ),
              )
            ),
            if(model.subtitle != null) Container(
              padding: const EdgeInsets.all(5),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)!.localizedText(model.subtitle),
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
    if (model.status == Status.archived) {
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
    _fetch();
  }

  _fetch() async {
    setState(() {
      _events = Database().getEvents(
        country: widget.country,
        searchText: _searchQueryController.value.text,
        user: currentUser,
        status: currentUser != null && currentUser!.isAdmin() ? _status : null,
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

