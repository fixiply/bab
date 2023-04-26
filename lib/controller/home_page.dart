import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/account_page.dart';
import 'package:bb/controller/admin/gallery_page.dart';
import 'package:bb/controller/brews_page.dart';
import 'package:bb/controller/calendar_page.dart';
import 'package:bb/controller/companies_page.dart';
import 'package:bb/controller/events_page.dart';
import 'package:bb/controller/ingredients_page.dart';
import 'package:bb/controller/inventory_page.dart';
import 'package:bb/controller/orders_page.dart';
import 'package:bb/controller/products_page.dart';
import 'package:bb/controller/receipts_page.dart';
import 'package:bb/controller/styles_page.dart';
import 'package:bb/controller/equipments_page.dart';
import 'package:bb/controller/tools_page.dart';
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';

// External package
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomePage extends StatefulWidget {
  final String? payload;
  HomePage({Key? key, this.payload}) : super(key: key);
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  SideMenuDisplayMode? displayMode;
  PageController _page = PageController(initialPage: 0);
  SideMenuController _sideMenu = SideMenuController(initialPage: 0);
  String? _version;

  @override
  void initState() {
    super.initState();
    _initialize();
    _configureSelectNotificationSubject();
    _sideMenu.addListener((page) {
      _page.jumpToPage(page);
    });
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (DeviceHelper.isDesktop || (DeviceHelper.isTablette(context) && orientation == Orientation.landscape)) {
          return Scaffold(
            body: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 300,
                  child: SideMenu(
                    controller: _sideMenu,
                    title: RichText(
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          TextSpan(text: 'Be', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white)),
                          WidgetSpan(
                              child: RotatedBox(
                                  quarterTurns: -1,
                                  child: Text(' And', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.white))
                              )
                          ),
                          TextSpan(text: 'Brew', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white)),
                        ],
                      ),
                    ),
                    footer: Text(_version ?? '', style: TextStyle(color: Colors.white)),
                    style: SideMenuStyle(
                      displayMode: displayMode,
                      backgroundColor: Theme.of(context).primaryColor,
                      selectedIconColor: Colors.white,
                      unselectedIconColor: Colors.white,
                      selectedTitleTextStyle: TextStyle(color: Colors.white),
                      unselectedTitleTextStyle: TextStyle(color: Colors.white),
                    ),
                    // List of SideMenuItem to show them on SideMenu
                    items: [
                      SideMenuItem(
                        priority: 0,
                        onTap: (page, _) => _sideMenu.changePage(page),
                        icon: Icon(Icons.home_outlined),
                        title: AppLocalizations.of(context)!.text('home')
                      ),
                      SideMenuItem(
                        priority: 1,
                        onTap: (page, _) => _sideMenu.changePage(page),
                        icon: Icon(Icons.sports_bar_outlined),
                        title: AppLocalizations.of(context)!.text('receipts'),
                      ),
                      SideMenuItem(
                        priority: 2,
                        onTap: (page, _) => _sideMenu.changePage(page),
                        icon: Icon(Icons.style_outlined),
                        title: AppLocalizations.of(context)!.text('beer_styles'),
                      ),
                      SideMenuItem(
                        priority: 3,
                        onTap: (page, _) => _sideMenu.changePage(page),
                        icon: Icon(Icons.science_outlined),
                        title: AppLocalizations.of(context)!.text('ingredients'),
                      ),
                      if (currentUser != null && currentUser!.isEditor()) SideMenuItem(
                        priority: 4,
                        onTap: (page, _) => _sideMenu.changePage(page),
                        icon: Icon(Icons.delete_outline),
                        title: AppLocalizations.of(context)!.text('equipments'),
                      ),
                      if (currentUser != null && currentUser!.isEditor()) SideMenuItem(
                        priority: 5,
                        onTap: (page, _) => _sideMenu.changePage(page),
                        icon: Icon(Icons.outdoor_grill_outlined),
                        title: AppLocalizations.of(context)!.text('brews'),
                      ),
                      if (currentUser != null && currentUser!.isEditor()) SideMenuItem(
                        priority: 6,
                        onTap: (page, _) => _sideMenu.changePage(page),
                        icon: Icon(Icons.inventory_outlined),
                        title: AppLocalizations.of(context)!.text('inventory'),
                      ),
                      if (currentUser != null) SideMenuItem(
                        priority: 7,
                        onTap: (page, _) => _sideMenu.changePage(page),
                        icon: Icon(Icons.calendar_month_outlined),
                        title: AppLocalizations.of(context)!.text('calendar'),
                      ),
                      if (currentUser != null) SideMenuItem(
                        priority: 8,
                        onTap: (page, _) => _sideMenu.changePage(page),
                        icon: Icon(Icons.build_outlined),
                        title: AppLocalizations.of(context)!.text('tools'),
                      ),
                      if (currentUser != null && currentUser!.isAdmin()) SideMenuItem(
                        priority: 9,
                        onTap: (page, _) => _sideMenu.changePage(page),
                        icon: Icon(Icons.local_offer_outlined),
                        title: AppLocalizations.of(context)!.text('orders'),
                      ),
                      if (currentUser != null && currentUser!.isAdmin()) SideMenuItem(
                        priority: 10,
                        onTap: (page, _) => _sideMenu.changePage(page),
                      icon: Icon(Icons.photo_library_outlined),
                      title: AppLocalizations.of(context)!.text('image_gallery'),
                    ),
                    if (DeviceHelper.isLargeScreen(context) && currentUser != null && currentUser!.isAdmin()) SideMenuItem(
                      priority: 11,
                      onTap: (page, _) => _sideMenu.changePage(page),
                      icon: Icon(Icons.article_outlined),
                      title: AppLocalizations.of(context)!.text('products'),
                    ),
                    if (DeviceHelper.isLargeScreen(context) && currentUser != null && currentUser!.isAdmin()) SideMenuItem(
                      priority: 12,
                      onTap: (page, _) => _sideMenu.changePage(page),
                      icon: Icon(Icons.groups_outlined),
                      title: AppLocalizations.of(context)!.text('companies'),
                    ),
                    SideMenuItem(
                      priority: 13,
                      onTap: (page, _) => _sideMenu.changePage(page),
                      icon: Icon(Icons.person_outline),
                      title: AppLocalizations.of(context)!.text('my_account'),
                    ),
                  ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _page,
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
                      Navigator(
                        onGenerateRoute: (RouteSettings settings) {
                          return MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (_) => EquipmentsPage(),
                          );
                        }
                      ),
                      Navigator(
                        onGenerateRoute: (RouteSettings settings) {
                          return MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (_) => BrewsPage(),
                          );
                        }
                      ),
                      Navigator(
                        onGenerateRoute: (RouteSettings settings) {
                          return MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (_) => InventoryPage(),
                          );
                        }
                      ),
                      Navigator(
                        onGenerateRoute: (RouteSettings settings) {
                          return MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (_) => CalendarPage(),
                          );
                        }
                      ),
                      Navigator(
                        onGenerateRoute: (RouteSettings settings) {
                          return MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (_) => ToolsPage(),
                          );
                        }
                      ),
                      Navigator(
                        onGenerateRoute: (RouteSettings settings) {
                          return MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (_) => OrdersPage(),
                          );
                        }
                      ),
                      Navigator(
                        onGenerateRoute: (RouteSettings settings) {
                          return MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (_) => GalleryPage([], close: false),
                          );
                        }
                      ),
                      Navigator(
                        onGenerateRoute: (RouteSettings settings) {
                          return MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (_) => ProductsPage(),
                          );
                        }
                      ),
                      Navigator(
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
              ]
            )
          );
        }
        return Scaffold(
          bottomNavigationBar: BottomNavigationBar(
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
          ),
          body: _showPage(),
        );
      }
    );
  }

  _initialize() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = 'V${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  List<BottomNavigationBarItem> _generateItems() {
    return [
      BottomNavigationBarItem(
        icon: ImageIcon(AssetImage('assets/images/logo.png')),
        label: AppLocalizations.of(context)!.text('home'),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.sports_bar_outlined),
        label: AppLocalizations.of(context)!.text('receipts'),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.style_outlined),
        label: AppLocalizations.of(context)!.text('styles'),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.science_outlined),
        label: AppLocalizations.of(context)!.text('ingredients'),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        label: AppLocalizations.of(context)!.text('my_account'),
      ),
    ];
  }

  void _configureSelectNotificationSubject() {
    if (widget.payload != null) {
      setState(() {
        _selectedIndex = 0;
      });
    }
  }

  Widget _showPage() {
    return PageView(
      controller: _page,
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

