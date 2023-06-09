import 'package:flutter/material.dart';

// Internal package
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/utils/device.dart';
import 'package:bab/widgets/dialogs/delete_dialog.dart';

class DevicesPage extends StatefulWidget {
  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: FillColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.text('my_devices')),
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white
      ),
      body: ListView.builder(
        controller: _controller,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: currentUser != null ? currentUser!.devices!.length : 0,
        itemBuilder: (context, index) {
          Device device = currentUser!.devices![index];
          return ListTile(
            title: Text(device.name!),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                bool confirm = await showDialog(
                  context: context,
                    builder: (BuildContext context) {
                    return DeleteDialog();
                  }
                );
                if (confirm) {
                  setState(() {
                    currentUser!.devices!.remove(device);
                  });
                  Database().update(currentUser);
                }
              }
            )
          );
        }
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

