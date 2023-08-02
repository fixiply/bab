import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/account_page.dart';
import 'package:bab/controller/admin/gallery_page.dart';
import 'package:bab/controller/brew_page.dart';
import 'package:bab/controller/brews_page.dart';
import 'package:bab/controller/calendar_page.dart';
import 'package:bab/controller/companies_page.dart';
import 'package:bab/controller/equipments_page.dart';
import 'package:bab/controller/event_page.dart';
import 'package:bab/controller/events_page.dart';
import 'package:bab/controller/ingredients_page.dart';
import 'package:bab/controller/inventory_page.dart';
import 'package:bab/controller/orders_page.dart';
import 'package:bab/controller/products_page.dart';
import 'package:bab/controller/receipts_page.dart';
import 'package:bab/controller/styles_page.dart';
import 'package:bab/controller/tools_page.dart';
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/main.dart';
import 'package:bab/models/brew_model.dart';
import 'package:bab/models/event_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/utils/edition_notifier.dart';

// External package
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';

class HomePage extends StatefulWidget {
  final String? payload;
  HomePage({Key? key, this.payload}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  int _selectedIndex = 0;
  PageController _page = PageController(initialPage: 0);
  SidebarXController _controller = SidebarXController(selectedIndex: 0, extended: true);
  String? _version;

  @override
  void initState() {
    super.initState();
    _initialize();
    _configureSelectNotificationSubject();
    _configureFirebaseMessaging();
    _controller.addListener(() {
      _page.jumpToPage(_controller.selectedIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: !DeviceHelper.isLargeScreen(context) ? BottomNavigationBar(
        showUnselectedLabels: true,
        unselectedFontSize: 14,
        type: BottomNavigationBarType.fixed,
        items: _generateItems(),
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Colors.black54,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
          _page.jumpToPage(index);
        },
      ) : null,
      drawer: DeviceHelper.isLargeScreen(context) ? _sideBarX() : null,
      body: Row(
        children: [
          if (DeviceHelper.isLargeScreen(context)) _sideBarX(),
          Expanded(
            child: PageView(
                controller: _page,
                onPageChanged: (index) {
                  _controller.selectIndex(index);
                },
                children: [
                  Navigator(
                      onGenerateRoute: (RouteSettings settings) {
                        return MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => EventsPage(),
                        );
                      }
                  ),
                  Navigator(
                      onGenerateRoute: (RouteSettings settings) {
                        return MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => ReceiptsPage(),
                        );
                      }
                  ),
                  Navigator(
                      onGenerateRoute: (RouteSettings settings) {
                        return MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => StylesPage(),
                        );
                      }
                  ),
                  Navigator(
                      onGenerateRoute: (RouteSettings settings) {
                        return MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => IngredientsPage(),
                        );
                      }
                  ),
                  if (currentUser != null && currentUser!.isEditor()) Navigator(
                      onGenerateRoute: (RouteSettings settings) {
                        return MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => EquipmentsPage(),
                        );
                      }
                  ),
                  if (currentUser != null && currentUser!.isEditor()) Navigator(
                      onGenerateRoute: (RouteSettings settings) {
                        return MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => BrewsPage(),
                        );
                      }
                  ),
                  if (currentUser != null && currentUser!.isEditor()) Navigator(
                      onGenerateRoute: (RouteSettings settings) {
                        return MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => InventoryPage(),
                        );
                      }
                  ),
                  if (currentUser != null) Navigator(
                      onGenerateRoute: (RouteSettings settings) {
                        return MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => CalendarPage(),
                        );
                      }
                  ),
                  if (currentUser != null) Navigator(
                      onGenerateRoute: (RouteSettings settings) {
                        return MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => ToolsPage(),
                        );
                      }
                  ),
                  if (currentUser != null && currentUser!.isAdmin()) Navigator(
                      onGenerateRoute: (RouteSettings settings) {
                        return MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => OrdersPage(),
                        );
                      }
                  ),
                  if (currentUser != null && currentUser!.isAdmin())Navigator(
                      onGenerateRoute: (RouteSettings settings) {
                        return MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => GalleryPage([], close: false),
                        );
                      }
                  ),
                  if (currentUser != null && currentUser!.isAdmin())Navigator(
                      onGenerateRoute: (RouteSettings settings) {
                        return MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => ProductsPage(),
                        );
                      }
                  ),
                  if (currentUser != null && currentUser!.isAdmin())Navigator(
                      onGenerateRoute: (RouteSettings settings) {
                        return MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => CompaniesPage(),
                        );
                      }
                  ),
                  Navigator(
                      onGenerateRoute: (RouteSettings settings) {
                        return MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => AccountPage(),
                        );
                      }
                  )
                ]
            ),
          )
        ],
      ),
    );
  }

  _initialize() async {
    final provider = Provider.of<ValuesNotifier>(context, listen: false);
    provider.addListener(() {
      setState(() {
        AppLocalizations.of(context)!.measure = provider.measure;
        AppLocalizations.of(context)!.gravity = provider.gravity;
      });
    });
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = 'V${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  _sideBarX() {
    return SidebarX(
      controller: _controller,
      theme: SidebarXTheme(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor
        ),
        textStyle: TextStyle(color: Colors.white, fontSize: 17),
        selectedTextStyle: const TextStyle(color: Colors.white, fontSize: 17),
        itemTextPadding: const EdgeInsets.only(left: 10),
        selectedItemTextPadding: const EdgeInsets.only(left: 10),
        selectedItemDecoration: BoxDecoration(
            color: Theme.of(context).highlightColor
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
          size: 20,
        ),
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 20,
        ),
      ),
      extendedTheme: SidebarXTheme(
        width: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
        ),
      ),
      headerBuilder: (context, extended) {
        if (extended == true) {
          return Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: RichText(
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  const TextSpan(text: 'Be',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white)),
                  const WidgetSpan(
                      child: RotatedBox(
                          quarterTurns: -1,
                          child: Text(' AND', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: Colors.white))
                      )
                  ),
                  const TextSpan(text: 'Brew',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white)),
                ],
              ),
            )
          );
        }
        return SizedBox(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 0),
            child: Image.asset('assets/images/logo.png', color: Colors.white),
          ),
        );
      },
      items: [
        if (DeviceHelper.isLargeScreen(context)) SidebarXItem(
            icon: Icons.home_outlined,
            label: AppLocalizations.of(context)!.text('home')
        ),
        if (DeviceHelper.isLargeScreen(context)) SidebarXItem(
          icon: Icons.sports_bar_outlined,
          label: AppLocalizations.of(context)!.text('receipts'),
        ),
        if (DeviceHelper.isLargeScreen(context)) SidebarXItem(
          icon: Icons.style_outlined,
          label: AppLocalizations.of(context)!.text('beer_styles'),
        ),
        if (DeviceHelper.isLargeScreen(context)) SidebarXItem(
          icon: Icons.science_outlined,
          label: AppLocalizations.of(context)!.text('ingredients'),
        ),
        if (currentUser != null && currentUser!.isEditor()) SidebarXItem(
          icon: Icons.delete_outline,
          label: AppLocalizations.of(context)!.text('equipments'),
        ),
        if (currentUser != null && currentUser!.isEditor()) SidebarXItem(
          icon: Icons.outdoor_grill_outlined,
          label: AppLocalizations.of(context)!.text('brews'),
        ),
        if (currentUser != null && currentUser!.isEditor()) SidebarXItem(
          icon: Icons.inventory_outlined,
          label: AppLocalizations.of(context)!.text('inventory'),
        ),
        if (currentUser != null) SidebarXItem(
          icon: Icons.calendar_month_outlined,
          label: AppLocalizations.of(context)!.text('calendar'),
        ),
        if (currentUser != null) SidebarXItem(
          icon: Icons.build_outlined,
          label: AppLocalizations.of(context)!.text('tools'),
        ),
        if (currentUser != null && currentUser!.isAdmin()) SidebarXItem(
          icon: Icons.local_offer_outlined,
          label: AppLocalizations.of(context)!.text('orders'),
        ),
        if (currentUser != null && currentUser!.isAdmin()) SidebarXItem(
          icon: Icons.photo_library_outlined,
          label: AppLocalizations.of(context)!.text('image_gallery'),
        ),
        if (currentUser != null && currentUser!.isAdmin()) SidebarXItem(
          icon: Icons.article_outlined,
          label: AppLocalizations.of(context)!.text('products'),
        ),
        if (currentUser != null && currentUser!.isAdmin()) SidebarXItem(
          icon: Icons.groups_outlined,
          label: AppLocalizations.of(context)!.text('companies'),
        ),
        if (DeviceHelper.isLargeScreen(context)) SidebarXItem(
          icon: Icons.person_outline,
          label: AppLocalizations.of(context)!.text('my_account'),
        ),
      ],
    );
  }

  _title(bool extended) {
    if (extended == true) {
      return Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: RichText(
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: [
                const TextSpan(text: 'Be',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white)),
                const WidgetSpan(
                    child: RotatedBox(
                        quarterTurns: -1,
                        child: Text(' AND', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: Colors.white))
                    )
                ),
                const TextSpan(text: 'Brew',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white)),
              ],
            ),
          )
      );
    }
  }

  List<BottomNavigationBarItem> _generateItems() {
    return [
      BottomNavigationBarItem(
        icon: const ImageIcon(AssetImage('assets/images/logo.png')),
        label: AppLocalizations.of(context)!.text('home'),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.sports_bar_outlined),
        label: AppLocalizations.of(context)!.text('receipts'),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.style_outlined),
        label: AppLocalizations.of(context)!.text('styles'),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.science_outlined),
        label: AppLocalizations.of(context)!.text('ingredients'),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.person_outline),
        label: AppLocalizations.of(context)!.text('my_account'),
      ),
    ];
  }

  void _configureSelectNotificationSubject() {
    if (widget.payload != null) {
      _payload(widget.payload!);
    }
    selectNotificationStream.stream.listen((String? payload) async {
      if (payload != null)  {
        _payload(payload);
      }
    });
    FirebaseMessaging.instance.getInitialMessage().then((value) {
      setState(() {
        if (value != null) {
          selectedNotificationPayload  = value.data['id'];
          selectNotificationStream.add(selectedNotificationPayload);
        }
      });
    });
  }

  void _configureFirebaseMessaging() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      if (notification != null) {
        String? uuid = message.data['id'];
        String? route = message.data['route'];
        _payload(uuid, route: route);
      }
    });

    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   RemoteNotification? notification = message.notification;
    //   if (notification != null) {
    //     String? payload = message.data['id'];
    //     _payload(payload);
    //   }
    // });
  }

  _payload(String? uuid, {String? route}) async {
    if (uuid != null && uuid.isNotEmpty) {
      if (route == 'brew') {
        BrewModel? model = await Database().getBrew(uuid);
        if (model != null) {
          setState(() {
            _selectedIndex = 0;
          });
          Navigator.push(context,
            MaterialPageRoute(builder: (context) =>
                BrewPage(model)
            ),
          );
        }
      } else {
        EventModel? model = await Database().getEvent(uuid);
        if (model != null) {
          setState(() {
            _selectedIndex = 5;
          });
          Navigator.push(context,
            MaterialPageRoute(builder: (context) =>
                EventPage(model, cache: false)
            ),
          );
        }
      }
    }
  }

  Widget _showPage() {
    return PageView(
      controller: _page,
      onPageChanged: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      children: [
        EventsPage(),
        ReceiptsPage(),
        StylesPage(),
        IngredientsPage(),
        AccountPage()
      ]
    );
  }
}

