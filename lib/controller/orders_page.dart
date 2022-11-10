import 'package:flutter/material.dart';

// Internal package
import 'package:bb/widgets/containers/empty_container.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';

// External package
import 'package:package_info_plus/package_info_plus.dart';

class OrdersPage extends StatefulWidget {
  _OrdersPageState createState() => new _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: FillColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.text('orders')),
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
