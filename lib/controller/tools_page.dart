import 'package:bab/widgets/containers/unit_container.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/widgets/basket_button.dart';
import 'package:bab/widgets/containers/abv_container.dart';
import 'package:bab/widgets/containers/carbonation_container.dart';
import 'package:bab/widgets/containers/efficiency_container.dart';
import 'package:bab/widgets/containers/ph_container.dart';
import 'package:bab/widgets/containers/water_container.dart';
import 'package:bab/widgets/custom_menu_anchor.dart';

// External package

class ToolsPage extends StatefulWidget {
  @override
  _ToolsPageState createState() => _ToolsPageState();
}

extension ListExpanded on List {
  bool isExpanded(int n) {
    for (Map element in this) {
      if (element.containsKey(n)) {
        return element[n];
      }
    }
    return false;
  }

  void set(int n, bool b) {
    bool found = false;
    for (Map element in this) {
      if (element.containsKey(n)) {
        element[n] = b;
        found = true;
      }
    }
    if (!found) {
      add({n: b});
    }
  }
}

class _ToolsPageState extends State<ToolsPage> with AutomaticKeepAliveClientMixin<ToolsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<int, bool>> _first =  [];
  final List<Map<int, bool>> _second =  [];
  final List<Map<int, bool>> _third =  [];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: FillColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.text('tools')),
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        actions: [
          BasketButton(),
          CustomMenuAnchor(
            showMeasures: true,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Générale', style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ExpansionPanelList(
              expandedHeaderPadding: EdgeInsets.zero,
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  _first.set(index, isExpanded);
                });
              },
              children: [
                ExpansionPanel(
                  canTapOnHeader: true,
                  isExpanded: _first.isExpanded(0),
                  headerBuilder: (context, isExpanded) {
                    return ListTile(
                      title: Text('ABV - Alcool par volume'),
                      subtitle: Text('Estimation du volume d\'alcool de votre bière et calcul d\'atténuation de la densité lors de la fermentation.'),
                    );
                  },
                  body: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.all(18),
                    child: ABVContainer(
                      showTitle: false,
                    )
                  )
                ),
                ExpansionPanel(
                  canTapOnHeader: true,
                  isExpanded: _first.isExpanded(1),
                  headerBuilder: (context, isExpanded) {
                    return ListTile(
                      title: Text('Convertisseurs d\'unités'),
                      subtitle: Text('Covertir les unités utilisées dans le brassage (couleur, densité, température et pression).'),
                    );
                  },
                  body: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.all(18),
                    child: UnitContainer(
                      showTitle: false,
                    )
                  )
                ),
              ]
            ),
            const SizedBox(height: 20),
            Text('Tout grain', style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ExpansionPanelList(
              expandedHeaderPadding: EdgeInsets.zero,
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  _second.set(index, isExpanded);
                });
              },
              children: [
                ExpansionPanel(
                  canTapOnHeader: true,
                  isExpanded: _second.isExpanded(0),
                  headerBuilder: (context, isExpanded) {
                    return ListTile(
                      title: Text('Efficacité de l\'empâtage'),
                      subtitle: Text('Calcul le pourcentage de sucres disponibles extraits des grains.'),
                    );
                  },
                  body: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.all(18),
                    child: EfficiencyContainer(
                      showTitle: false,
                      showVolume: true,
                    )
                  )
                ),
                ExpansionPanel(
                  canTapOnHeader: true,
                  isExpanded: _second.isExpanded(1),
                  headerBuilder: (context, isExpanded) {
                    return ListTile(
                      title: Text('Eau d\'empâtage et de rincage'),
                      subtitle: Text('Calcul la quantité d\'eau et de rinçage requise pour votre brassin.'),
                    );
                  },
                  body: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.all(18),
                    child: WaterContainer(
                      showTitle: false,
                      showVolume: true,
                    )
                  )
                ),
                ExpansionPanel(
                  canTapOnHeader: true,
                  isExpanded: _second.isExpanded(2),
                  headerBuilder: (context, isExpanded) {
                    return ListTile(
                      title: Text('Ajustement du pH de l\'eau'),
                      subtitle: Text('Calcul la quantité d\'acide pour atteindre le pH souhaité.'),
                    );
                  },
                  body: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.all(18),
                    child: PHContainer(
                      showTitle: false,
                      showVolume: true,
                      target: 5.4,
                    )
                  )
                )
              ]
            ),
            const SizedBox(height: 20),
            Text('Conditionnement', style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ExpansionPanelList(
              expandedHeaderPadding: EdgeInsets.zero,
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  _third.set(index, isExpanded);
                });
              },
              children: [
                ExpansionPanel(
                  canTapOnHeader: true,
                  isExpanded: _third.isExpanded(0),
                  headerBuilder: (context, isExpanded) {
                    return ListTile(
                      title: Text('Refermentation en bouteille'),
                      subtitle: Text('Calcul la quantité de sucre nécessaire lors de l\'embouteillage d\'une bière pour atteindre le niveau de carbonatation souhaité.'),
                    );
                  },
                  body: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.all(18),
                    child: CarbonationContainer(
                      showTitle: false,
                      showVolume: true,
                    )
                  )
                ),
              ]
            ),
          ]
        )
      )
    );
  }
}

