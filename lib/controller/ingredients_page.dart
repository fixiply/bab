import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/basket_page.dart';
import 'package:bab/controller/fermentables_page.dart';
import 'package:bab/controller/hops_page.dart';
import 'package:bab/controller/misc_page.dart';
import 'package:bab/controller/yeasts_page.dart';
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/widgets/custom_drawer.dart';
import 'package:bab/widgets/custom_menu_button.dart';

// External package
import 'package:badges/badges.dart' as badge;

class IngredientsPage extends StatefulWidget {
  IngredientsPage({Key? key}) : super(key: key);

  @override
  _IngredientsPageState createState() => _IngredientsPageState();
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
              badgeAnimation: const badge.BadgeAnimation.slide(
                // animationDuration: const Duration(milliseconds: 300),
              ),
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
              publish: false,
              filtered: false,
              archived: false,
              measures: true,
            )
          ],
          bottom: PreferredSize(
            preferredSize: _tabBar.preferredSize,
            child: ColoredBox(
              color: FillColor,
              child: _tabBar,
            ),
          ),
        ),
        drawer: !DeviceHelper.isLargeScreen(context) && currentUser != null ? CustomDrawer(context) : null,
        body: TabBarView(
          children: [
            FermentablesPage(allowEditing: currentUser != null),
            HopsPage(allowEditing: currentUser != null),
            YeastsPage(allowEditing: currentUser != null),
            MiscPage(allowEditing: currentUser != null),
          ]
        ),
      )
    );
  }

  _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 10)
        )
    );
  }
}

