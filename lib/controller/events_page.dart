import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/basket_page.dart';
import 'package:bb/utils/basket_notifier.dart';
import 'package:bb/controller/event_page.dart';
import 'package:bb/controller/forms/form_event_page.dart';
import 'package:bb/models/event_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/utils/edition_notifier.dart';
import 'package:bb/widgets/containers/empty_container.dart';
import 'package:bb/widgets/containers/error_container.dart';
import 'package:bb/widgets/containers/image_container.dart';
import 'package:bb/widgets/containers/shimmer_container.dart';
import 'package:bb/widgets/custom_drawer.dart';
import 'package:bb/widgets/builders/full_widget_page.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';

// External package
import 'package:badges/badges.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventsPage extends StatefulWidget {
  EventsPage({Key? key}) : super(key: key);
  _EventsPageState createState() => new _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late ScrollController? _controller;
  TextEditingController _searchQueryController = TextEditingController();
  Future<List<EventModel>>? _events;
  int _baskets = 0;

  // Edition mode
  bool _editable = false;
  bool _remove = false;
  bool _hidden = false;

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
        title: _buildSearchField(),
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
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
          if (currentUser != null && currentUser!.isAdmin()) PopupMenuButton(
            icon: Icon(Icons.more_vert),
            tooltip: AppLocalizations.of(context)!.text('display'),
            onSelected: (value) async {
              if (value == 1) {
                await Database().publishAll();
              } else if (value == 3) {
                bool checked = !_remove;
                if (checked) {
                  _hidden = false;
                }
                setState(() { _remove = checked; });
                _fetch();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              PopupMenuItem(
                value: 1,
                child: Text(AppLocalizations.of(context)!.text('publish_everything')),
              ),
              PopupMenuItem(
                value: 2,
                child: SwitchListTile(
                  value: _editable,
                  title: Text(AppLocalizations.of(context)!.text('edit'), softWrap: false),
                  onChanged: (value) async {
                    bool checked = !_editable;
                    Provider.of<EditionNotifier>(context, listen: false).setEditable(checked);
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setBool(EDIT_KEY, checked);
                    setState(() { _editable = checked; });
                    Navigator.pop(context);
                  },
                )
              ),
              PopupMenuItem(
                enabled: false,
                value: null,
                child: Text(AppLocalizations.of(context)!.text('filtered')),
              ),
              CheckedPopupMenuItem(
                child: Text(AppLocalizations.of(context)!.text('archives')),
                value: 3,
                checked: _remove,
              ),
              CheckedPopupMenuItem(
                child: Text(AppLocalizations.of(context)!.text('hidden')),
                value: 4,
                checked: _hidden,
              )
            ]
          ),
        ]
      ),
      drawer: CustomDrawer(context),
      body: Container(
        child: RefreshIndicator(
          onRefresh: () => _fetch(),
          child: FutureBuilder<List<EventModel>>(
            future: _events,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.length == 0) {
                  if (_searchQueryController.text.length > 0) {
                    return EmptyContainer(message: AppLocalizations.of(context)!.text('no_result'));
                  }
                  return EmptyContainer(message: AppLocalizations.of(context)!.text('no_event'));
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
      ),
      floatingActionButton: Visibility(
        visible: _editable && currentUser != null && currentUser!.isAdmin(),
        child: FloatingActionButton(
          onPressed: _new,
          backgroundColor: Theme.of(context).primaryColor,
          tooltip: AppLocalizations.of(context)!.text('new'),
          child: const Icon(Icons.add)
        )
      )
    );
  }

  Widget _buildSearchField() {
    return Container(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: FillColor
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: TextField(
              controller: _searchQueryController,
              decoration: InputDecoration(
                icon: Padding(
                    padding: EdgeInsets.only(left: 4.0),
                    child: Icon(Icons.search, color: Theme.of(context).primaryColor)
                ),
                hintText: AppLocalizations.of(context)!.text('search_hint'),
                hintStyle: TextStyle(color: Theme.of(context).primaryColor),
                border: InputBorder.none
              ),
              style: TextStyle(fontSize: 16.0),
              onChanged: (query) {
                return _fetch();
              },
            )
          ),
          if (_searchQueryController.text.length > 0) IconButton(
            icon: Icon(Icons.clear, color: Theme.of(context).primaryColor),
            onPressed: () {
              _searchQueryController.clear();
              _fetch();
            }
          )
        ],
      )
    );
  }

  Widget _item(EventModel model, bool grid) {
    return Padding(
      padding: grid ? EdgeInsets.all(6.0) : EdgeInsets.symmetric(vertical: 6.0, horizontal: 15.0),
      child: Card(
        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
        elevation: 1.0,
        child: InkWell(
          onTap: () async {
            if (model.page != null && model.page!.isNotEmpty) {
              var data = JsonWidgetData.fromDynamic(model.page!);
              if (data != null) {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        FullWidgetPage(
                          data: data,
                        ),
                  ),
                );
              }
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return EventPage(model);
              }));
            }
          },
          onDoubleTap: currentUser != null && currentUser!.isAdmin() ? () {
            _edit(model);
          } : null,
          onLongPress: currentUser != null && currentUser!.isAdmin() ? () {
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
              Container(
                height: 180,
                width: MediaQuery.of(context).size.width / 2.5,
                child: ImageContainer(
                  model.getImages(),
                  fit: null,
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
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          model.title!,
                          overflow: grid ? TextOverflow.ellipsis : null,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      )
                    ),
                    if (model.subtitle != null) Container(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                      child: Text(
                        model.subtitle ?? '',
                        overflow: grid ? TextOverflow.ellipsis : null,
                        style: TextStyle(
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
            Container(
              height: grid ? 140 : 180,
              width: double.infinity,
              child: ImageContainer(
                  model.getImages(),
                  cache: currentUser != null && currentUser!.isAdmin() == false,
                  emptyImage: Image.asset('assets/images/no_image.png', fit: BoxFit.scaleDown)
              )
            ),
            if(model.title != null && model.title!.length > 0) Flexible(
              child: Container(
                padding: EdgeInsets.all(5),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    model.title!,
                    overflow: grid ? TextOverflow.ellipsis : null,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.left,
                  ),
                )
              )
            ),
            if(model.subtitle != null && model.subtitle!.length > 0) Flexible(
              child: Container(
                padding: EdgeInsets.all(5),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    model.subtitle ?? '',
                    overflow: grid ? TextOverflow.ellipsis : null,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.left,
                  ),
                )
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
      icon = Icon(Icons.delete, color: Colors.white);
      color = PointerColor;
      message = AppLocalizations.of(context)!.text('archive');
    } else if (model.status == Status.pending) {
      visible = true;
      icon = Icon(Icons.hourglass_empty, color: Colors.white);
      message = AppLocalizations.of(context)!.text('pending');
    }
    return Visibility(
      visible: visible,
      child: Container(
        padding: EdgeInsets.all(4),
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
    final provider = Provider.of<EditionNotifier>(context, listen: false);
    _editable = provider.editable;
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
      _events = Database().getEvents(searchText: _searchQueryController.value.text);
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

