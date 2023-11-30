import 'package:flutter/material.dart';

// Internal package
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/utils/locale_notifier.dart';

// External package
import 'package:app_settings/app_settings.dart';
import 'package:provider/provider.dart';

enum Menu {settings, options, publish, archived, hidden, imported}


class CustomMenuAnchor extends StatefulWidget {
  bool showPublish;
  bool showFilters;
  bool isArchived;
  bool isHidden;
  bool showMeasures;
  String? importLabel;
  PopupMenuItemSelected? onSelected;

  CustomMenuAnchor({Key? key, this.showPublish = false, this.showFilters = false, this.isArchived = false, this.isHidden = false, this.showMeasures = false, this.importLabel, this.onSelected}): super(key: key);
  @override
  CustomMenuAnchorState createState() => CustomMenuAnchorState();
}

class CustomMenuAnchorState extends State<CustomMenuAnchor>  {
  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: [
        if (!DeviceHelper.isDesktop) MenuItemButton(
          child: Text(AppLocalizations.of(context)!.text('alert_settings')),
          onPressed: () => AppSettings.openNotificationSettings(),
        ),
        SubmenuButton(
          child: Text(AppLocalizations.of(context)!.text('languages')),
          menuChildren: <Widget>[
            CheckboxMenuButton(
              child: Text(AppLocalizations.of(context)!.text('english')),
              value: const Locale('en', 'US') == AppLocalizations.of(context)!.locale,
              onChanged: (value) {
                Provider.of<LocaleNotifier>(context, listen: false).setLocale(const Locale('en', 'US'));
                widget.onSelected?.call(const Locale('en', 'US'));
              }
            ),
            CheckboxMenuButton(
              child: Text(AppLocalizations.of(context)!.text('french')),
              value: const Locale('fr', 'FR') == AppLocalizations.of(context)!.locale,
              onChanged: (value) {
                Provider.of<LocaleNotifier>(context, listen: false).setLocale(const Locale('fr', 'FR'));
                widget.onSelected?.call(const Locale('fr', 'FR'));
              }
            ),
          ]
        ),
        if (widget.showMeasures) SubmenuButton(
          child: Text(AppLocalizations.of(context)!.text('measuring_systems')),
          menuChildren: <Widget>[
            CheckboxMenuButton(
              child: Text(AppLocalizations.of(context)!.text('metric')),
              value: Unit.metric == AppLocalizations.of(context)!.unit,
              onChanged: (value) {
                Provider.of<LocaleNotifier>(context, listen: false).setUnit(Unit.metric);
                widget.onSelected?.call(Unit.metric);
              }
            ),
            CheckboxMenuButton(
              child: Text(AppLocalizations.of(context)!.text('us_standard')),
              value: Unit.us == AppLocalizations.of(context)!.unit,
              onChanged: (value) {
                Provider.of<LocaleNotifier>(context, listen: false).setUnit(Unit.us);
                widget.onSelected?.call(Unit.us);
              }
            ),
          ]
        ),
        if (widget.showMeasures) SubmenuButton(
          child: Text(AppLocalizations.of(context)!.text('gravity_units')),
          menuChildren: <Widget>[
            CheckboxMenuButton(
              child: Text(AppLocalizations.of(context)!.text('gravity')),
              value: Gravity.sg == AppLocalizations.of(context)!.gravity,
              onChanged: (value) {
                Provider.of<LocaleNotifier>(context, listen: false).setGravity(Gravity.sg);
                widget.onSelected?.call(Gravity.sg);
              }
            ),
            CheckboxMenuButton(
              child: Text('Plato °P'),
              value: Gravity.plato == AppLocalizations.of(context)!.gravity,
              onChanged: (value) {
                Provider.of<LocaleNotifier>(context, listen: false).setGravity(Gravity.plato);
                widget.onSelected?.call(Gravity.plato);
              }
            ),
            CheckboxMenuButton(
              child: Text('Brix °Bx'),
              value: Gravity.brix == AppLocalizations.of(context)!.gravity,
              onChanged: (value) {
                Provider.of<LocaleNotifier>(context, listen: false).setGravity(Gravity.brix);
                widget.onSelected?.call(Gravity.brix);
              }
            ),
          ]
        ),
        if (widget.showPublish) MenuItemButton(
            child: Text(AppLocalizations.of(context)!.text('publish_everything')),
            onPressed: () async {
              await Database().publishAll();
              widget.onSelected?.call(Menu.publish);
            }
        ),
        if (widget.showFilters) SubmenuButton(
          child: Text(AppLocalizations.of(context)!.text('filtered')),
          menuChildren: <Widget>[
            CheckboxMenuButton(
              child: Text(AppLocalizations.of(context)!.text('archives')),
              value: widget.isArchived,
              onChanged: (value) {
                widget.onSelected?.call(Menu.archived);
              }
            ),
            CheckboxMenuButton(
              child: Text(AppLocalizations.of(context)!.text('hidden')),
              value: widget.isHidden,
              onChanged: (value) {
                widget.onSelected?.call(Menu.hidden);
              }
            ),
          ]
        ),
        if (widget.importLabel != null && widget.importLabel!.isNotEmpty) MenuItemButton(
          child: Text(widget.importLabel!),
          onPressed: () async {
            widget.onSelected?.call(Menu.imported);
          }
        ),
      ],
      builder:  (BuildContext context, MenuController controller, Widget? child) {
        return IconButton(
          icon: const Icon(Icons.more_vert),
          tooltip: MaterialLocalizations.of(context).showMenuTooltip,
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      }
    );
  }
}
