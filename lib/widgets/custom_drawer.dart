import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/admin/gallery_page.dart';
import 'package:bb/controller/brews_page.dart';
import 'package:bb/controller/calendar_page.dart';
import 'package:bb/controller/companies_page.dart';
import 'package:bb/controller/inventory_page.dart';
import 'package:bb/controller/orders_page.dart';
import 'package:bb/controller/products_page.dart';
import 'package:bb/controller/equipments_page.dart';
import 'package:bb/controller/tools_page.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';

class CustomDrawer<Object> extends Drawer {
  CustomDrawer(BuildContext context, {Key? key}) : super(
    key: key,
    semanticLabel: AppLocalizations.of(context)!.text('menu'),
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height : 120.0,
          child: DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Image.asset('assets/images/white_logo_transparent_background.png'),
          )
        ),
        if (currentUser != null && currentUser!.isEditor()) ListTile(
          title: Text(AppLocalizations.of(context)!.text('equipments'),
              style: TextStyle(fontSize: 18)
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return EquipmentsPage();
            })).then((value) {
              Navigator.pop(context);
            });
          },
        ),
        if (currentUser != null && currentUser!.isEditor()) ListTile(
          title: Text(AppLocalizations.of(context)!.text('brews'),
              style: TextStyle(fontSize: 18)
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return BrewsPage();
            })).then((value) {
              Navigator.pop(context);
            });
          },
        ),
        if (currentUser != null && currentUser!.isEditor()) ListTile(
          title: Text(AppLocalizations.of(context)!.text('inventory'),
              style: TextStyle(fontSize: 18)
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return InventoryPage();
            })).then((value) {
              Navigator.pop(context);
            });
          },
        ),
        if (currentUser != null && currentUser!.isEditor()) ListTile(
          title: Text(AppLocalizations.of(context)!.text('tools'),
              style: TextStyle(fontSize: 18)
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ToolsPage();
            })).then((value) {
              Navigator.pop(context);
            });
          },
        ),
        if (currentUser != null) Divider(height: 10),
        if (currentUser != null) ListTile(
          title: Text(AppLocalizations.of(context)!.text('calendar'),
              style: TextStyle(fontSize: 18)
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return CalendarPage();
            })).then((value) {
              Navigator.pop(context);
            });
          },
        ),
        if (currentUser != null && currentUser!.isAdmin()) ListTile(
          title: Text(AppLocalizations.of(context)!.text('orders'),
              style: TextStyle(fontSize: 18)
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return OrdersPage();
            })).then((value) {
              Navigator.pop(context);
            });
          },
        ),
        if (currentUser != null && currentUser!.isAdmin()) ListTile(
          title: Text(AppLocalizations.of(context)!.text('image_gallery'),
              style: TextStyle(fontSize: 18)
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return GalleryPage([]);
            })).then((value) {
              Navigator.pop(context);
            });
          },
        ),
        if (currentUser != null && currentUser!.isAdmin()) ListTile(
          title: Text(AppLocalizations.of(context)!.text('products'),
            style: TextStyle(fontSize: 18)
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ProductsPage();
            })).then((value) {
              Navigator.pop(context);
            });
          },
        ),
        if (currentUser != null && currentUser!.isAdmin()) ListTile(
          title: Text(AppLocalizations.of(context)!.text('companies'),
              style: TextStyle(fontSize: 18)
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return CompaniesPage();
            })).then((value) {
              Navigator.pop(context);
            });
          },
        ),
      ],
    ),
  );
}
