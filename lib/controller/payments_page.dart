import 'package:flutter/material.dart';

// Internal package
import 'package:bb/utils/database.dart';
import 'package:bb/controller/forms/form_payment_page.dart';
import 'package:bb/models/payment_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';

// External package
import 'package:uuid/uuid.dart';

class PaymentsPage extends StatefulWidget {
  _PaymentsPageState createState() => new _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
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
    List<PaymentModel>? payments = currentUser != null ? currentUser!.payments : [];
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: FillColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.text('payment_methods')),
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        actions: <Widget> [
          if (payments!.isNotEmpty) TextButton(
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
            child: Text(AppLocalizations.of(context)!.text('registered_cards'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
          ),
          for(PaymentModel payment in payments) ListTileTheme(
            tileColor: Colors.white,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Container(
                padding:  EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (payment.name != null) Text(payment.name!),
                    if (payment.address != null) Text(payment.address!),
                    if (payment.city != null) Text('${payment.city!}, ${payment.zip!}'),
                  ],
                )
              ),
              trailing: _modify ? Container(
                  color: Colors.white,
                  child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _edit(payment);
                      }
                  )
              ): null,
            )
          ),
          TextButton.icon(
            icon: Icon(Icons.add),
            label: Text(AppLocalizations.of(context)!.text('add_card').toUpperCase(), textAlign: TextAlign.left),
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
    PaymentModel newModel = PaymentModel();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormPaymentPage(newModel);
    })).then((value) {
      if (value != null) {
        setState(() {
          newModel.uuid = Uuid().v4();
          currentUser!.payments!.add(newModel);
          Database().update(currentUser).then((value) async {
            _showSnackbar(AppLocalizations.of(context)!.text('saved_credit_card'));
          }).onError((e,s) {
            _showSnackbar(e.toString());
          });
        });
      }
    });
  }

  _edit(PaymentModel model) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormPaymentPage(model);
    })).then((value) {
      if (value != null) {
        setState(() {
          Database().update(currentUser).then((value) async {
            _showSnackbar(AppLocalizations.of(context)!.text('saved_credit_card'));
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

