import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/gallery_page.dart';
import 'package:bb/controller/styles_page.dart';
import 'package:bb/utils/app_localizations.dart';

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
        ListTile(
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
        ListTile(
          title: Text(AppLocalizations.of(context)!.text('beer_styles'),
              style: TextStyle(fontSize: 18)
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return StylesPage();
            })).then((value) {
              Navigator.pop(context);
            });
          },
        ),
      ],
    ),
  );
}
