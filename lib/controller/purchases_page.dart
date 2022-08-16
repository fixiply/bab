import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/forms/form_beer_page.dart';
import 'package:bb/models/beer_model.dart';
import 'package:bb/models/image_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/widgets/containers/empty_container.dart';
import 'package:bb/widgets/containers/error_container.dart';
import 'package:bb/widgets/custom_image.dart';
import 'package:bb/widgets/dialogs/delete_dialog.dart';

class PurchasesPage extends StatefulWidget {
  _PurchasesPageState createState() => new _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: FillColor,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.text('my_purchases')),
          elevation: 0,
          foregroundColor: Theme.of(context).primaryColor,
          backgroundColor: Colors.white
        ),
        body: Container(
        )
    );
  }

  _initialize() async {
    _fetch();
  }

  _fetch() async {
    setState(() {
    });
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

