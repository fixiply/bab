import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/fermenters_page.dart';
import 'package:bab/controller/tanks_page.dart';
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/widgets/basket_button.dart';
import 'package:bab/widgets/custom_menu_anchor.dart';

// External package

class EquipmentsPage extends StatefulWidget {
  EquipmentsPage({Key? key}) : super(key: key);
  @override
  _EquipmentsPageState createState() => _EquipmentsPageState();
}

class _EquipmentsPageState extends State<EquipmentsPage> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<EquipmentsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _tanksKey = GlobalKey<TanksPageState>();
  final _fermentersKey = GlobalKey<FermentersPageState>();

  @override
  bool get wantKeepAlive => true;

  TabBar get _tabBar => TabBar(
    indicatorSize: TabBarIndicatorSize.tab,
    indicator: ShapeDecoration(
      color: Theme.of(context).primaryColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
    ),
    tabs: [
      Tab(icon: Icon(Icons.takeout_dining_outlined, color: Theme.of(context).primaryColor), iconMargin: EdgeInsets.zero, child: Text(AppLocalizations.of(context)!.text('tanks'), overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).primaryColor))),
      Tab(icon: Icon(Icons.propane_tank_outlined, color: Theme.of(context).primaryColor), iconMargin: EdgeInsets.zero, child: Text(AppLocalizations.of(context)!.text('fermenters'), overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).primaryColor))),
    ],
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: FillColor,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.text('equipments')),
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
                if (_tanksKey.currentState != null) {
                  _tanksKey.currentState!.fetch();
                }
                if (_fermentersKey.currentState != null) {
                  _fermentersKey.currentState!.fetch();
                }
              },
            ),
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
            TanksPage(key: _tanksKey, allowEditing: currentUser != null, allowAdding: true),
            FermentersPage(key: _fermentersKey, allowEditing: currentUser != null, allowAdding: true),
          ]
        ),
      )
    );
  }
}

