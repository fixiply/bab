import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/admin/gallery_page.dart';
import 'package:bab/controller/brews_page.dart';
import 'package:bab/controller/calendar_page.dart';
import 'package:bab/controller/companies_page.dart';
import 'package:bab/controller/inventory_page.dart';
import 'package:bab/controller/orders_page.dart';
import 'package:bab/controller/products_page.dart';
import 'package:bab/controller/equipments_page.dart';
import 'package:bab/controller/tools_page.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';

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
        if (currentUser != null) ListTile(
          title: Text(AppLocalizations.of(context)!.text('equipments'),
            style: const TextStyle(fontSize: 18)
          ),
          onTap: () {
            Navigator.of(context, rootNavigator:true).push( // ensures fullscreen
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return EquipmentsPage();
                }
              )
            );
          },
        ),
        if (currentUser != null) ListTile(
          title: Text(AppLocalizations.of(context)!.text('brews'),
              style: const TextStyle(fontSize: 18)
          ),
          onTap: () {
            Navigator.of(context, rootNavigator:true).push( // ensures fullscreen
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return BrewsPage();
                }
              )
            );
          },
        ),
        if (currentUser != null) ListTile(
          title: Text(AppLocalizations.of(context)!.text('inventory'),
              style: const TextStyle(fontSize: 18)
          ),
          onTap: () {
            Navigator.of(context, rootNavigator:true).push( // ensures fullscreen
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return InventoryPage();
                }
              )
            );
          },
        ),
        if (currentUser != null) ListTile(
          title: Text(AppLocalizations.of(context)!.text('tools'),
              style: const TextStyle(fontSize: 18)
          ),
          onTap: () {
            Navigator.of(context, rootNavigator:true).push( // ensures fullscreen
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return ToolsPage();
                }
              )
            );
          },
        ),
        if (currentUser != null) const Divider(height: 10),
        if (currentUser != null) ListTile(
          title: Text(AppLocalizations.of(context)!.text('calendar'),
              style: const TextStyle(fontSize: 18)
          ),
          onTap: () {
            Navigator.of(context, rootNavigator:true).push( // ensures fullscreen
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return CalendarPage();
                }
              )
            );
          },
        ),
        if (currentUser != null && currentUser!.isAdmin()) ListTile(
          title: Text(AppLocalizations.of(context)!.text('orders'),
              style: const TextStyle(fontSize: 18)
          ),
          onTap: () {
            Navigator.of(context, rootNavigator:true).push( // ensures fullscreen
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return OrdersPage();
                }
              )
            );
          },
        ),
        if (currentUser != null && currentUser!.isAdmin()) ListTile(
          title: Text(AppLocalizations.of(context)!.text('image_gallery'),
              style: const TextStyle(fontSize: 18)
          ),
          onTap: () {
            Navigator.of(context, rootNavigator:true).push( // ensures fullscreen
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return GalleryPage(const []);
                }
              )
            );
          },
        ),
        if (currentUser != null && currentUser!.isAdmin()) ListTile(
          title: Text(AppLocalizations.of(context)!.text('products'),
            style: const TextStyle(fontSize: 18)
          ),
          onTap: () {
            Navigator.of(context, rootNavigator:true).push( // ensures fullscreen
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return ProductsPage();
                }
              )
            );
          },
        ),
        if (currentUser != null && currentUser!.isAdmin()) ListTile(
          title: Text(AppLocalizations.of(context)!.text('companies'),
              style: const TextStyle(fontSize: 18)
          ),
          onTap: () {
            Navigator.of(context, rootNavigator:true).push( // ensures fullscreen
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return CompaniesPage();
                }
              )
            );
          },
        ),
      ],
    ),
  );
}
