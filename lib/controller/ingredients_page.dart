import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/basket_page.dart';
import 'package:bb/controller/fermentables_page.dart';
import 'package:bb/controller/hops_page.dart';
import 'package:bb/controller/miscellaneous_page.dart';
import 'package:bb/controller/yeasts_page.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/locale_notifier.dart';

// External package
import 'package:badges/badges.dart' as badge;
import 'package:provider/provider.dart';

class IngredientsPage extends StatefulWidget {
  IngredientsPage({Key? key}) : super(key: key);
  _IngredientsPageState createState() => new _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<IngredientsPage> {
  int _baskets = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  bool get wantKeepAlive => true;

  TabBar get _tabBar => TabBar(
    indicator: ShapeDecoration(
      color: Theme.of(context).primaryColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
    ),
    tabs: [
      Tab(icon: Icon(Icons.grain_outlined, color: Theme.of(context).primaryColor), iconMargin: EdgeInsets.zero, child: Text(AppLocalizations.of(context)!.text('fermentables'), overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).primaryColor))),
      Tab(icon: Icon(Icons.grass_outlined, color: Theme.of(context).primaryColor), iconMargin: EdgeInsets.zero, child: Text(AppLocalizations.of(context)!.text('hops'), overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).primaryColor))),
      Tab(icon: Icon(Icons.bubble_chart_outlined, color: Theme.of(context).primaryColor), iconMargin: EdgeInsets.zero, child: Text(AppLocalizations.of(context)!.text('yeasts'), overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).primaryColor))),
      Tab(icon: Icon(Icons.eco_outlined, color: Theme.of(context).primaryColor), iconMargin: EdgeInsets.zero, child: Text(AppLocalizations.of(context)!.text('miscellaneous'), overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).primaryColor))),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: FillColor,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.text('ingredients')),
          elevation: 0,
          foregroundColor: Theme.of(context).primaryColor,
          backgroundColor: Colors.white,
          actions: [
            badge.Badge(
              position: badge.BadgePosition.topEnd(top: 0, end: 3),
              animationDuration: Duration(milliseconds: 300),
              animationType: badge.BadgeAnimationType.slide,
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
            PopupMenuButton(
              icon: Icon(Icons.more_vert),
              tooltip: AppLocalizations.of(context)!.text('display'),
              onSelected: (value) async {
                if (value is Locale) {
                  Provider.of<LocaleNotifier>(context, listen: false).set(value);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                PopupMenuItem(
                  enabled: false,
                  value: null,
                  child: Text(AppLocalizations.of(context)!.text('language')),
                ),
                CheckedPopupMenuItem(
                  child: Text(AppLocalizations.of(context)!.text('english')),
                  value: const Locale('en', 'US'),
                  checked: const Locale('en', 'US') == AppLocalizations.of(context)!.locale,
                ),
                CheckedPopupMenuItem(
                  child: Text(AppLocalizations.of(context)!.text('french')),
                  value: const Locale('fr', 'FR'),
                  checked: const Locale('fr', 'FR') == AppLocalizations.of(context)!.locale,
                ),
              ]
            ),
          ],
          bottom: PreferredSize(
            preferredSize: _tabBar.preferredSize,
            child: ColoredBox(
              color: FillColor,
              child: _tabBar,
            ),
          ),
        ),
        body: TabBarView(
          children: [
            FermentablesPage(),
            HopsPage(),
            YeastsPage(),
            MiscellaneousPage(),
          ]
        ),
      )
    );
  }

  _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(message),
            duration: Duration(seconds: 10)
        )
    );
  }
}

