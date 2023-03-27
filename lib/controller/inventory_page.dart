
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/tables/fermentables_data_table.dart';
import 'package:bb/controller/tables/hops_data_table.dart';
import 'package:bb/controller/tables/miscellaneous_data_table.dart';
import 'package:bb/controller/tables/yeasts_data_table.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';

// External package

class InventoryPage extends StatefulWidget {
  InventoryPage({Key? key}) : super(key: key);
  _InventoryPageState createState() => new _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<InventoryPage> {
  late TabController _tabController;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  bool get wantKeepAlive => true;

  TabBar get _tabBar => TabBar(
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
            FermentablesDataTable(color: Colors.white),
            HopsDataTable(color: Colors.white),
            YeastsDataTable(color: Colors.white),
            MiscellaneousDataTable(color: Colors.white),
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

