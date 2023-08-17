import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/about_page.dart';
import 'package:bab/controller/address_page.dart';
import 'package:bab/controller/basket_page.dart';
import 'package:bab/controller/devices_page.dart';
import 'package:bab/controller/login_page.dart';
import 'package:bab/controller/payments_page.dart';
import 'package:bab/controller/purchases_page.dart';
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/basket_notifier.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/widgets/custom_drawer.dart';
import 'package:bab/widgets/custom_menu_button.dart';
import 'package:bab/widgets/dialogs/confirm_dialog.dart';

// External package
import 'package:badges/badges.dart' as badge;
import 'package:app_settings/app_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatefulWidget {
  AccountPage({Key? key}) : super(key: key);
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  int _baskets = 0;

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
          badge.Badge(
            position: badge.BadgePosition.topEnd(top: 0, end: 3),
            badgeAnimation: const badge.BadgeAnimation.slide(
              // animationDuration: const Duration(milliseconds: 300),
            ),
            showBadge: _baskets > 0,
            badgeContent: _baskets > 0 ? Text(
              _baskets.toString(),
              style: const TextStyle(color: Colors.white),
            ) : null,
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return BasketPage();
                }));
              },
            ),
          ),
          CustomMenuButton(
            context: context,
            publish: false,
            filtered: false,
            archived: false,
          )
        ]
      ),
      drawer: !DeviceHelper.isLargeScreen(context) && currentUser != null ? CustomDrawer(context) : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start ,
          children: <Widget>[
            if (currentUser == null) const SizedBox(height: 30),
            if (currentUser == null) Align(
              child: Text(AppLocalizations.of(context)!.text('login_account')),
            ),
            const SizedBox(height: 8),
            if (currentUser == null) Align(
              child: TextButton(
                child: Text(AppLocalizations.of(context)!.text('login'), style: TextStyle(color: Theme.of(context).primaryColor)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const LoginPage();
                  }));
                },
                style: TextButton.styleFrom(shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  side: BorderSide(color: Theme.of(context).primaryColor),
                )),
              ),
            ),
            if (currentUser == null) const SizedBox(height: 40),
            Text(AppLocalizations.of(context)!.text('my_settings'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Container(
              color: Colors.white,
              padding: EdgeInsets.zero,
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: <Widget> [
                  if (currentUser != null) ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.local_offer_outlined),
                    title: Text(AppLocalizations.of(context)!.text('my_purchases')),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return PurchasesPage();
                      }));
                    },
                  ),
                  if (currentUser != null) ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.devices),
                    title: Text(AppLocalizations.of(context)!.text('my_devices')),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return DevicesPage();
                      }));
                    },
                  ),
                  if (currentUser != null) ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.credit_card),
                    title: Text(AppLocalizations.of(context)!.text('payment_methods')),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return PaymentsPage();
                      }));
                    },
                  ),
                  if (currentUser != null) ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.local_shipping_outlined),
                    title: Text(AppLocalizations.of(context)!.text('delivery_addresses')),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return AddressPage();
                      }));
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.help_outline),
                    title: Text(AppLocalizations.of(context)!.text('customer_support')),
                  ),
                  if (!foundation.kIsWeb) ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.notifications),
                    title: Text(AppLocalizations.of(context)!.text('alert_settings')),
                    onTap: () {
                      AppSettings.openNotificationSettings();
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.info_outline),
                    title: Text(AppLocalizations.of(context)!.text('about')),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return AboutPage();
                      }));
                    },
                  ),
                  if (currentUser != null) ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.cancel),
                    title: Text(AppLocalizations.of(context)!.text('logout')),
                    subtitle: Text(currentUser!.user!.email!),
                    onTap: () async {
                      bool confirm = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                        return ConfirmDialog(
                          content: Text(AppLocalizations.of(context)!.text('disconnect')),
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

