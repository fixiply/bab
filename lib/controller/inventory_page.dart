import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/tables/fermentables_data_table.dart';
import 'package:bab/controller/tables/hops_data_table.dart';
import 'package:bab/controller/tables/misc_data_table.dart';
import 'package:bab/controller/tables/yeasts_data_table.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/widgets/basket_button.dart';
import 'package:bab/widgets/containers/empty_container.dart';
import 'package:bab/widgets/custom_menu_anchor.dart';

// External package

class InventoryPage extends StatefulWidget {
  InventoryPage({Key? key}) : super(key: key);

  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<InventoryPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  bool get wantKeepAlive => true;

  TabBar get _tabBar => TabBar(
    indicatorSize: TabBarIndicatorSize.tab,
    indicator: ShapeDecoration(
      color: Theme.of(context).primaryColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
    ),
    tabs: [
      Tab(icon: Icon(Icons.grain_outlined, color: Theme.of(context).primaryColor), iconMargin: EdgeInsets.zero, child: Text(AppLocalizations.of(context)!.text('fermentables'), style: TextStyle(color: Theme.of(context).primaryColor))),
      Tab(icon: Icon(Icons.grass_outlined, color: Theme.of(context).primaryColor), iconMargin: EdgeInsets.zero, child: Text(AppLocalizations.of(context)!.text('hops'), style: TextStyle(color: Theme.of(context).primaryColor))),
      Tab(icon: Icon(Icons.bubble_chart_outlined, color: Theme.of(context).primaryColor), iconMargin: EdgeInsets.zero, child: Text(AppLocalizations.of(context)!.text('yeasts'), style: TextStyle(color: Theme.of(context).primaryColor))),
      Tab(icon: Icon(Icons.eco_outlined, color: Theme.of(context).primaryColor), iconMargin: EdgeInsets.zero, child: Text(AppLocalizations.of(context)!.text('miscellaneous'), style: TextStyle(color: Theme.of(context).primaryColor))),
    ],
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: FillColor,
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.text('inventory')),
          elevation: 0,
          foregroundColor: Theme.of(context).primaryColor,
          backgroundColor: Colors.white
      ),
      body: EmptyContainer(message: 'En construction')
    );
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: FillColor,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.text('inventory')),
          elevation: 0,
          foregroundColor: Theme.of(context).primaryColor,
          backgroundColor: Colors.white,
          actions: [
            BasketButton(),
            CustomMenuAnchor(
              showMeasures: true,
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
        body: TabBarView(
          children: [
            FermentablesDataTable(data: const [], color: Colors.white),
            HopsDataTable(data: const [], color: Colors.white),
            YeastsDataTable(data: const [], color: Colors.white),
            MiscDataTable(data: const [], color: Colors.white),
          ]
        ),
      )
    );
  }
}

