import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as Foundation;

// Internal package
import 'package:bb/controller/account_page.dart';
import 'package:bb/controller/admin/gallery_page.dart';
import 'package:bb/controller/brews_page.dart';
import 'package:bb/controller/calendar_page.dart';
import 'package:bb/controller/companies_page.dart';
import 'package:bb/controller/events_page.dart';
import 'package:bb/controller/ingredients_page.dart';
import 'package:bb/controller/orders_page.dart';
import 'package:bb/controller/products_page.dart';
import 'package:bb/controller/receipts_page.dart';
import 'package:bb/controller/styles_page.dart';
import 'package:bb/controller/tanks_page.dart';
import 'package:bb/controller/tools_page.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/edition_notifier.dart';

// External package
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final String? payload;
  HomePage({Key? key, this.payload}) : super(key: key);
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  PageController _page = PageController();
  bool? _editable = false;
  String? _version;

  @override
  void initState() {
    super.initState();
    _initialize();
    _configureSelectNotificationSubject();
  }

  @override
  void dispose() {
    // selectNotificationSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (ClassHelper.isIOS()) {
    //   return CupertinoTabScaffold(
    //     tabBar: CupertinoTabBar(
    //       items: _generateItems(),
    //       currentIndex: _selectedIndex,
    //       onTap: (int index) {
    //         setState(() {
    //           _selectedIndex = index;
    //         });
    //       },
    //     ),
    //     tabBuilder: (BuildContext context, int index) {
    //       return CupertinoTabView(
    //         builder: (BuildContext context) {
    //           return CupertinoPageScaffold(child: _showPage()!);
    //           return _showPage()!;
    //         }
    //       );
    //     }
    //   );
    // }
    return Scaffold(
      bottomNavigationBar: !Foundation.kIsWeb ? BottomNavigationBar(
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
        },
      ) : null,
      body: !Foundation.kIsWeb ? _showPage() :
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SideMenu(
            // Page controller to manage a PageView
            controller: _page,
            // Will shows on top of all items, it can be a logo or a Title text
            title: Text(AppLocalizations.of(context)!.text('menu'), style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white)),
            // Will show on bottom of SideMenu when displayMode was SideMenuDisplayMode.open
            footer: Text(_version!, style: TextStyle(color: Colors.white)),
            // Notify when display mode changed
            onDisplayModeChanged: (mode) {
              print(mode);
            },
            style: SideMenuStyle(
              backgroundColor: Theme.of(context).primaryColor,
              selectedIconColor: Colors.white,
              unselectedIconColor: Colors.white,
              selectedTitleTextStyle: TextStyle(color: Colors.white),
              unselectedTitleTextStyle: TextStyle(color: Colors.white),
            ),
            // List of SideMenuItem to show them on SideMenu
            items: [
              if (currentUser != null && currentUser!.isAdmin()) SideMenuItem(
                priority: 0,
                onTap: () => _page.jumpToPage(0),
                icon: Icon(Icons.home_outlined),
                title: AppLocalizations.of(context)!.text('home')
              ),
              SideMenuItem(
                priority: 1,
                onTap: () => _page.jumpToPage(1),
                icon: Icon(Icons.sports_bar_outlined),
                title: AppLocalizations.of(context)!.text('receipts'),
              ),
              SideMenuItem(
                priority: 2,
                onTap: () => _page.jumpToPage(2),
                icon: Icon(Icons.style_outlined),
                title: AppLocalizations.of(context)!.text('beer_styles'),
              ),
              if (currentUser != null && currentUser!.isEditor()) SideMenuItem(
                priority: 3,
                onTap: () => _page.jumpToPage(3),
                icon: Icon(Icons.propane_tank_outlined),
                title: AppLocalizations.of(context)!.text('my_tanks'),
              ),
              if (currentUser != null && currentUser!.isEditor()) SideMenuItem(
                priority: 4,
                onTap: () => _page.jumpToPage(4),
                icon: Icon(Icons.outdoor_grill_outlined),
                title: AppLocalizations.of(context)!.text('my_brews'),
              ),
              if (currentUser != null && currentUser!.isEditor()) SideMenuItem(
                priority: 5,
                onTap: () => _page.jumpToPage(5),
                icon: Icon(Icons.science_outlined),
                title: AppLocalizations.of(context)!.text('my_ingredients'),
              ),
              if (currentUser != null && currentUser!.isEditor()) SideMenuItem(
                priority: 6,
                onTap: () => _page.jumpToPage(6),
                icon: Icon(Icons.build_outlined),
                title: AppLocalizations.of(context)!.text('tools'),
              ),
              if (Foundation.kIsWeb && currentUser != null && currentUser!.hasRole()) SideMenuItem(
                priority: 7,
                onTap: () => _page.jumpToPage(7),
                icon: Icon(Icons.calendar_month),
                title: AppLocalizations.of(context)!.text('calendar'),
              ),
              if (Foundation.kIsWeb && currentUser != null && currentUser!.isAdmin()) SideMenuItem(
                priority: 8,
                onTap: () => _page.jumpToPage(8),
                icon: Icon(Icons.local_offer_outlined),
                title: AppLocalizations.of(context)!.text('orders'),
              ),
              if (currentUser != null && currentUser!.isAdmin()) SideMenuItem(
                priority: 9,
                onTap: () => _page.jumpToPage(9),
                icon: Icon(Icons.photo_library_outlined),
                title: AppLocalizations.of(context)!.text('image_gallery'),
              ),
              if (Foundation.kIsWeb && currentUser != null && currentUser!.isAdmin()) SideMenuItem(
                priority: 10,
                onTap: () => _page.jumpToPage(10),
                icon: Icon(Icons.article_outlined),
                title: AppLocalizations.of(context)!.text('products'),
              ),
              if (Foundation.kIsWeb && currentUser != null && currentUser!.isAdmin()) SideMenuItem(
                priority: 11,
                onTap: () => _page.jumpToPage(11),
                icon: Icon(Icons.groups),
                title: AppLocalizations.of(context)!.text('companies'),
              ),
              SideMenuItem(
                priority: 12,
                onTap: () => _page.jumpToPage(12),
                icon: Icon(Icons.person_outline),
                title: AppLocalizations.of(context)!.text('my_account'),
              ),
            ],
          ),
          Expanded(
            child: PageView(
              controller: _page,
              children: [
                EventsPage(),
                ReceiptsPage(),
                StylesPage(),
                TanksPage(),
                BrewsPage(),
                IngredientsPage(),
                ToolsPage(),
                CalendarPage(),
                OrdersPage(),
                GalleryPage([], close: false),
                ProductsPage(),
                CompaniesPage(),
                AccountPage(),
              ]
            )
          )
        ]
      )
    );
  }

  _initialize() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = 'V${packageInfo.version} (${packageInfo.buildNumber})';
    });
    final provider = Provider.of<EditionNotifier>(context, listen: false);
    _editable = provider.editable;
    provider.addListener(() {
      if (!mounted) return;
      setState(() {
        _editable = provider.editable;
      });
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

  Widget? _showPage() {
    switch (_selectedIndex) {
      case 0: return EventsPage();
      case 1: return ReceiptsPage();
      case 2: return StylesPage();
      case 3: return AccountPage();
      case 4: return GalleryPage([], close: false);
      case 5: return ProductsPage();
      case 6: return CompaniesPage();
    }
  }
}

