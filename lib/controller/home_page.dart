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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';

class HomePage extends StatefulWidget {
  final String? payload;
  const HomePage({Key? key, this.payload}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  int _selectedIndex = 0;
  int _numberOfPages = 0;
  final PageController _page = PageController(initialPage: 0);
  final SidebarXController _controller = SidebarXController(selectedIndex: 0, extended: true);

  @override
  void dispose() {
    _page.dispose();
     super.dispose();
  }

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Jump to last page (Account) if the user connects or disconnects.
    if (_page.hasClients && _page.page != 0) {
      debugPrint('didChangeDependencies ${_page.page} ${_controller.selectedIndex} $_numberOfPages');
      _page.jumpToPage(_numberOfPages);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = DeviceHelper.isLargeScreen(context);
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
            child: PageView(
              controller: _page,
              pageSnapping: false,
              onPageChanged: (index) {
                _controller.selectIndex(index);
              },
              children: _generateItems(isLargeScreen)
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
          return Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: RichText(
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: const [
                  TextSpan(text: 'Be', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white)),
                  WidgetSpan(
                    child: RotatedBox(
                        quarterTurns: -1,
                        child: Text(' AND', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: Colors.white))
                    )
                  ),
                  TextSpan(text: 'Brew', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white)),
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

  List<Widget> _generateItems(bool isLargeScreen) {
    List<Widget> pages = [
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
      if (isLargeScreen && currentUser != null && currentUser!.isEditor()) Navigator(
          onGenerateRoute: (RouteSettings settings) {
            return MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => EquipmentsPage(),
            );
          }
      ),
      if (isLargeScreen && currentUser != null && currentUser!.isEditor()) Navigator(
          onGenerateRoute: (RouteSettings settings) {
            return MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => BrewsPage(),
            );
          }
      ),
      if (isLargeScreen && currentUser != null && currentUser!.isEditor()) Navigator(
          onGenerateRoute: (RouteSettings settings) {
            return MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => InventoryPage(),
            );
          }
      ),
      if (isLargeScreen && currentUser != null) Navigator(
          onGenerateRoute: (RouteSettings settings) {
            return MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => CalendarPage(),
            );
          }
      ),
      if (isLargeScreen && currentUser != null) Navigator(
          onGenerateRoute: (RouteSettings settings) {
            return MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => ToolsPage(),
            );
          }
      ),
      if (isLargeScreen && currentUser != null && currentUser!.isAdmin()) Navigator(
          onGenerateRoute: (RouteSettings settings) {
            return MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => OrdersPage(),
            );
          }
      ),
      if (isLargeScreen && currentUser != null && currentUser!.isAdmin()) Navigator(
          onGenerateRoute: (RouteSettings settings) {
            return MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => GalleryPage(const [], close: false),
            );
          }
      ),
      if (isLargeScreen && currentUser != null && currentUser!.isAdmin()) Navigator(
          onGenerateRoute: (RouteSettings settings) {
            return MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => ProductsPage(),
            );
          }
      ),
      if (isLargeScreen && currentUser != null && currentUser!.isAdmin()) Navigator(
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
    ];
    _numberOfPages = pages.length;
    return pages;
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