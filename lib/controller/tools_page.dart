import 'package:flutter/material.dart';

// Internal package
import 'package:bb/models/payment_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';

// External package
import 'package:package_info_plus/package_info_plus.dart';

class ToolsPage extends StatefulWidget {
  _ToolsPageState createState() => new _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController? _controller;
  String? _version;

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
        title: Text(AppLocalizations.of(context)!.text('tools')),
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white
      ),
      body: ListView(
        controller: _controller,
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Text(AppLocalizations.of(context)!.text('about_this_app'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
          ),
          ListTileTheme(
            tileColor: Colors.white,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Container(
                padding:  EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.text('version')),
                    Text(_version ?? ''),
                  ],
                )
              ),
            )
          ),
        ]
      )
    );
  }

  _initialize() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = 'V${packageInfo.version} (${packageInfo.buildNumber})';
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

