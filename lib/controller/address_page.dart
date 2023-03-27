import 'package:flutter/material.dart';

// Internal package
import 'package:bb/utils/database.dart';
import 'package:bb/controller/forms/form_address_page.dart';
import 'package:bb/utils/adress.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';

// External package
import 'package:uuid/uuid.dart';

class AddressPage extends StatefulWidget {
  _AddressPageState createState() => new _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController? _controller;
  bool _modify = false;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    List<Adress>? addresses = currentUser != null ? currentUser!.addresses : [];
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: FillColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.text('delivery_addresses')),
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        actions: <Widget> [
          if (addresses!.isNotEmpty) TextButton(
            child: Text(AppLocalizations.of(context)!.text(_modify ? 'ok' : 'modify').toUpperCase(), style: TextStyle(color: Theme.of(context).primaryColor)),
            onPressed: () {
              setState(() {
                _modify = !_modify;
              });
            }
          ),
        ]
      ),
      body: ListView(
        controller: _controller,
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Text(AppLocalizations.of(context)!.text('registered_addresses'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
          ),
          for(Adress address in addresses) ListTileTheme(
            tileColor: Colors.white,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Container(
                padding:  EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (address.name != null) Text(address.name!),
                    if (address.address != null) Text(address.address!),
                    if (address.city != null) Text('${address.city!}, ${address.zip!}'),
                    if (address.phone != null) Text(address.phone!)
                  ],
                )
              ),
              trailing: _modify ? Container(
                color: Colors.white,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _edit(address);
                  }
                )
              ): null,
            ),
          ),
          TextButton.icon(
            icon: Icon(Icons.add),
            label: Text(AppLocalizations.of(context)!.text('add_address').toUpperCase()),
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: _new
          )
        ]
      )
    );
  }

  _new() async {
    Adress newModel = Adress();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormAddressPage(newModel);
    })).then((value) {
      if (value != null) {
        setState(() {
          newModel.uuid = Uuid().v4();
          currentUser!.addresses!.add(newModel);
          Database().update(currentUser).then((value) async {
            _showSnackbar(AppLocalizations.of(context)!.text('saved_address'));
          }).onError((e,s) {
            _showSnackbar(e.toString());
          });
        });
      }
    });
  }

  _edit(Adress model) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormAddressPage(model);
    })).then((value) {
      if (value != null) {
        setState(() {
          Database().update(currentUser).then((value) async {
            _showSnackbar(AppLocalizations.of(context)!.text('saved_address'));
          }).onError((e,s) {
            _showSnackbar(e.toString());
          });
        });
      }
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

