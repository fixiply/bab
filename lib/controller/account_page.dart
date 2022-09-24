import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/address_page.dart';
import 'package:bb/controller/basket_page.dart';
import 'package:bb/utils/basket_notifier.dart';
import 'package:bb/controller/login_page.dart';
import 'package:bb/controller/payments_page.dart';
import 'package:bb/controller/purchases_page.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/edition_notifier.dart';
import 'package:bb/widgets/custom_drawer.dart';
import 'package:bb/widgets/dialogs/confirm_dialog.dart';

// External package
import 'package:badges/badges.dart';
import 'package:app_settings/app_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatefulWidget {
  AccountPage({Key? key}) : super(key: key);
  _AccountPageState createState() => new _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  int _baskets = 0;
  // Edition mode
  bool _editable = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(AppLocalizations.of(context)!.text('my_account')),
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        actions: [
          Badge(
            position: BadgePosition.topEnd(top: 0, end: 3),
            animationDuration: Duration(milliseconds: 300),
            animationType: BadgeAnimationType.slide,
            showBadge: _baskets > 0,
            badgeContent: _baskets > 0 ? Text(
              _baskets.toString(),
              style: TextStyle(color: Colors.white),
            ) : null,
            child: IconButton(
              icon: Icon(Icons.shopping_cart_outlined),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return BasketPage();
                }));
              },
            ),
          ),
        ]
      ),
      drawer: _editable && currentUser != null && currentUser!.isEditor() ? CustomDrawer(context) : null,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start ,
          children: <Widget>[
            if (currentUser == null) const SizedBox(height: 30),
            if (currentUser == null) Align(
              child: const Text(
                'Connectez-vous pour accéder à votre compte',
              ),
            ),
            const SizedBox(height: 8),
            if (currentUser == null) Align(
              child: TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return LoginPage();
                  }));
                },
                style: TextButton.styleFrom(shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  side: BorderSide(color: Theme.of(context).primaryColor),
                )),
                child: Text('Connectez-vous', style: TextStyle(color: Theme.of(context).primaryColor)),
              ),
            ),
            if (currentUser == null) const SizedBox(height: 40),
            Text(AppLocalizations.of(context)!.text('my_settings'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Container(
              color: Colors.white,
              padding: EdgeInsets.zero,
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: <Widget> [
                  if (currentUser != null) ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.local_offer_outlined),
                    title: Text(AppLocalizations.of(context)!.text('my_purchases')),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return PurchasesPage();
                      }));
                    },
                  ),
                  if (currentUser != null) ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.credit_card),
                    title: Text(AppLocalizations.of(context)!.text('payment_methods')),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return PaymentsPage();
                      }));
                    },
                  ),
                  if (currentUser != null) ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.local_shipping_outlined),
                    title: Text(AppLocalizations.of(context)!.text('delivery_addresses')),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return AddressPage();
                      }));
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.help_outline),
                    title: Text(AppLocalizations.of(context)!.text('customer_support')),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.notifications),
                    title: Text(AppLocalizations.of(context)!.text('alert_settings')),
                    onTap: () {
                      AppSettings.openNotificationSettings();
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.info_outline),
                    title: Text(AppLocalizations.of(context)!.text('about')),
                  ),
                  if (currentUser != null) ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.cancel),
                    title: Text(AppLocalizations.of(context)!.text('logout')),
                    subtitle: Text(currentUser!.user!.email!),
                    onTap: () async {
                      bool confirm = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                        return ConfirmDialog(
                          content: Text('Voulez-vous vraiment vous déconnecter ?'),
                          );
                        }
                      );
                      if (confirm) {
                        FirebaseAuth.instance.signOut();
                        setState(() {
                          currentUser = null;
                        });
                      }
                    },
                  ),
                ],
              )
            )
          ]
        ),
      ),
    );
  }

  _initialize() async {
    final provider = Provider.of<EditionNotifier>(context, listen: false);
    _editable = provider.editable;
    final basketProvider = Provider.of<BasketNotifier>(context, listen: false);
    _baskets = basketProvider.size;
    basketProvider.addListener(() {
      if (!mounted) return;
      setState(() {
        _baskets = basketProvider.size;
      });
    });
    // _fetch();
  }
}

