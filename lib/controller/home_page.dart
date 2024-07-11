import 'dart:async';

import 'package:flutter/material.dart';

// Internal package
import 'package:bab/main.dart';
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
import 'package:bab/controller/recipes_page.dart';
import 'package:bab/controller/styles_page.dart';
import 'package:bab/controller/tools_page.dart';
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/models/brew_model.dart';
import 'package:bab/models/event_model.dart';
import 'package:bab/models/user_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';

// External package
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sidebarx/sidebarx.dart';

class HomePage extends StatefulWidget {
  final String? payload;
  const HomePage({Key? key, this.payload}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> with AutomaticKeepAliveClientMixin<HomePage> {
  int _selectedIndex = 0;
  final PageController _page = PageController(initialPage: 0);
  final SidebarXController _controller = SidebarXController(selectedIndex: 0, extended: true);

  List<Widget> _pages = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _initialize();
    });
    _configureSelectNotificationSubject();
    _configureFirebaseMessaging();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = DeviceHelper.isLargeScreen;
    return Scaffold(
      bottomNavigationBar: !isLargeScreen ? BottomNavigationBar(
        showUnselectedLabels: true,
        unselectedFontSize: 14,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const ImageIcon(AssetImage('assets/images/logo.png')),
            label: AppLocalizations.of(context)!.text('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.sports_bar_outlined),
            label: AppLocalizations.of(context)!.text('recipes'),
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
        ],
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
      body: Row(
        children: [
          if (isLargeScreen) _sideBarX(),
          Expanded(
            child: PageView.builder(
              controller: _page,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
                _controller.selectIndex(index);
              },
              itemBuilder: (BuildContext context, int index) {
                if (_pages.isEmpty || index > _pages.length-1) {
                  return null;
                }
                return _pages[index];
              },
            ),
          )
        ],
      ),
    );
  }

  _initialize() async {
    _generateItems();
    userNotifier.addListener(() {
      _generateItems();
      if (_page.hasClients && ((userNotifier.user != null && _page.page == 4) || (userNotifier.user == null && _page.page == 9))) {
        // Jump to last page (My account) if the user connects or disconnects.
        Timer(Duration(milliseconds: 500), () {
          _controller.selectIndex(_pages.length - 1);
        });
      }
    });
    _controller.addListener(() {
      _page.jumpToPage(_controller.selectedIndex);
    });
  }

  _sideBarX() {
    return SidebarX(
      controller: _controller,
      theme: SidebarXTheme(
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 17),
        selectedTextStyle: const TextStyle(color: Colors.white, fontSize: 17),
        hoverTextStyle: const TextStyle(color: Colors.white, fontSize: 17),
        itemTextPadding: const EdgeInsets.only(left: 10),
        selectedItemTextPadding: const EdgeInsets.only(left: 10),
        selectedItemDecoration: BoxDecoration(
            color: Theme.of(context).highlightColor
        ),
        iconTheme: const IconThemeData(
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
          return SizedBox(
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Image.asset('assets/images/header.png', width: 100)
            )
          );
        }
        return SizedBox(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
            child: Image.asset('assets/images/logo.png', color: Colors.white),
          ),
        );
      },
      items: [
        if (DeviceHelper.isLargeScreen) SidebarXItem(
            icon: Icons.home_outlined,
            label: AppLocalizations.of(context)!.text('home')
        ),
        if (DeviceHelper.isLargeScreen) SidebarXItem(
          icon: Icons.sports_bar_outlined,
          label: AppLocalizations.of(context)!.text('recipes'),
        ),
        if (DeviceHelper.isLargeScreen) SidebarXItem(
          icon: Icons.style_outlined,
          label: AppLocalizations.of(context)!.text('beer_styles'),
        ),
        if (DeviceHelper.isLargeScreen) SidebarXItem(
          icon: Icons.science_outlined,
          label: AppLocalizations.of(context)!.text('ingredients'),
        ),
        if (currentUser != null) SidebarXItem(
          icon: Icons.takeout_dining_outlined,
          label: AppLocalizations.of(context)!.text('equipments'),
        ),
        if (currentUser != null) SidebarXItem(
          icon: Icons.outdoor_grill_outlined,
          label: AppLocalizations.of(context)!.text('brews'),
        ),
        if (currentUser != null) SidebarXItem(
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
        if (DeviceHelper.isLargeScreen) SidebarXItem(
          icon: Icons.person_outline,
          label: AppLocalizations.of(context)!.text('my_account'),
        ),
      ],
    );
  }

  void _generateItems() {
    final UserModel? user = userNotifier.user;
    final isLargeScreen = DeviceHelper.isLargeScreen;
    setState(() {
      _pages = [
        Navigator(
            key: GlobalKey(),
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => EventsPage(country: AppLocalizations.of(context)!.locale.countryCode),
              );
            }
        ),
        Navigator(
            key: GlobalKey(),
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => RecipesPage(),
              );
            }
        ),
        Navigator(
            key: GlobalKey(),
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => StylesPage(),
              );
            }
        ),
        Navigator(
            key: GlobalKey(),
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => IngredientsPage(),
              );
            }
        ),
        if (isLargeScreen && user != null) Navigator(
            key: GlobalKey(),
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => EquipmentsPage(),
              );
            }
        ),
        if (isLargeScreen && user != null) Navigator(
            key: GlobalKey(),
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => BrewsPage(),
              );
            }
        ),
        if (isLargeScreen && user != null) Navigator(
            key: GlobalKey(),
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => InventoryPage(),
              );
            }
        ),
        if (isLargeScreen && user != null) Navigator(
            key: GlobalKey(),
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => CalendarPage(),
              );
            }
        ),
        if (isLargeScreen && user != null) Navigator(
            key: GlobalKey(),
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => ToolsPage(),
              );
            }
        ),
        if (isLargeScreen && user != null && user.isAdmin()) Navigator(
            key: GlobalKey(),
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => OrdersPage(),
              );
            }
        ),
        if (isLargeScreen && user != null && user.isAdmin()) Navigator(
            key: GlobalKey(),
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => GalleryPage(const [], close: false),
              );
            }
        ),
        if (isLargeScreen && user != null && user.isAdmin()) Navigator(
            key: GlobalKey(),
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => ProductsPage(),
              );
            }
        ),
        if (isLargeScreen && user != null && user.isAdmin()) Navigator(
            key: GlobalKey(),
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => CompaniesPage(),
              );
            }
        ),
        Navigator(
            key: GlobalKey(),
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => AccountPage(),
              );
            }
        )
      ];
    });
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
}