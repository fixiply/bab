import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/fermentables_page.dart';
import 'package:bab/controller/hops_page.dart';
import 'package:bab/controller/misc_page.dart';
import 'package:bab/controller/yeasts_page.dart';
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/widgets/basket_button.dart';
import 'package:bab/widgets/custom_drawer.dart';
import 'package:bab/widgets/custom_menu_anchor.dart';

// External package

class IngredientsPage extends StatefulWidget {
  IngredientsPage({Key? key}) : super(key: key);

  @override
  _IngredientsPageState createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<IngredientsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _fermentablesKey = GlobalKey<FermentablesPageState>();
  final _hopsKey = GlobalKey<HopsPageState>();
  final _yeastsKey = GlobalKey<YeastsPageState>();
  final _miscKey = GlobalKey<MiscPageState>();

  @override
  bool get wantKeepAlive => true;

  TabBar get _tabBar => TabBar(
    indicatorSize: TabBarIndicatorSize.tab,
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
    super.build(context);
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
            BasketButton(),
            if (DeviceHelper.isDesktop) IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.refresh),
              tooltip: AppLocalizations.of(context)!.text('refresh'),
              onPressed: () {
                if (_fermentablesKey.currentState != null) {
                  _fermentablesKey.currentState!.fetch();
                }
                if (_hopsKey.currentState != null) {
                  _hopsKey.currentState!.fetch();
                }
                if (_yeastsKey.currentState != null) {
                  _yeastsKey.currentState!.fetch();
                }
                if (_miscKey.currentState != null) {
                  _miscKey.currentState!.fetch();
                }
              },
            ),
            CustomMenuAnchor()
          ],
          bottom: PreferredSize(
            preferredSize: _tabBar.preferredSize,
            child: ColoredBox(
              color: FillColor,
              child: _tabBar,
            ),
          ),
        ),
        drawer: !DeviceHelper.isLargeScreen && currentUser != null ? CustomDrawer(context) : null,
        body: TabBarView(
          children: [
            FermentablesPage(key: _fermentablesKey, allowEditing: currentUser != null),
            HopsPage(key: _hopsKey, allowEditing: currentUser != null),
            YeastsPage(key: _yeastsKey, allowEditing: currentUser != null),
            MiscPage(key: _miscKey, allowEditing: currentUser != null),
          ]
        ),
      )
    );
  }
}

