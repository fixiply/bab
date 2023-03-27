import 'package:flutter/material.dart';

// Internal package
import 'package:bb/widgets/containers/empty_container.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';

// External package
import 'package:package_info_plus/package_info_plus.dart';

class BrewsPage extends StatefulWidget {
  _BrewsPageState createState() => new _BrewsPageState();
}

class _BrewsPageState extends State<BrewsPage> with AutomaticKeepAliveClientMixin<BrewsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: FillColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.text('brews')),
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white
      ),
      body: EmptyContainer(message: 'En construction')
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

