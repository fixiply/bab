import 'package:bab/utils/edition_notifier.dart';
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

abstract class _CustomMenuAnchor extends MenuAnchor {
  _CustomMenuAnchor({Key? key, required BuildContext context, bool publish = false, bool filtered = false, bool archived = false, bool hidden = false, bool measures = false, String? importLabel, PopupMenuItemSelected? onSelected}) : super(
      key: key,
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
              onChanged: (value) => Provider.of<LocaleNotifier>(context, listen: false).set(const Locale('en', 'US'))
            ),
            CheckboxMenuButton(
              child: Text(AppLocalizations.of(context)!.text('french')),
              value: const Locale('fr', 'FR') == AppLocalizations.of(context)!.locale,
                onChanged: (value) => Provider.of<LocaleNotifier>(context, listen: false).set(const Locale('fr', 'FR'))
            ),
          ]
        ),
        if (measures) SubmenuButton(
          child: Text(AppLocalizations.of(context)!.text('measuring_systems')),
          menuChildren: <Widget>[
            CheckboxMenuButton(
              child: Text(AppLocalizations.of(context)!.text('metric')),
              value: Measure.metric == AppLocalizations.of(context)!.measure,
              onChanged: (value) {
                final provider = Provider.of<ValuesNotifier>(context, listen: false);
                provider.measure = Measure.metric;
                onSelected?.call(provider.measure);
              }
            ),
            CheckboxMenuButton(
              child: Text(AppLocalizations.of(context)!.text('imperial')),
              value: Measure.imperial == AppLocalizations.of(context)!.measure,
              onChanged: (value) {
                final provider = Provider.of<ValuesNotifier>(context, listen: false);
                provider.measure = Measure.imperial;
                onSelected?.call(provider.measure);
              }
            ),
          ]
        ),
        if (measures) SubmenuButton(
          child: Text(AppLocalizations.of(context)!.text('gravity_units')),
          menuChildren: <Widget>[
            CheckboxMenuButton(
              child: Text(AppLocalizations.of(context)!.text('gravity')),
              value: Gravity.sg == AppLocalizations.of(context)!.gravity,
              onChanged: (value) {
                final provider = Provider.of<ValuesNotifier>(context, listen: false);
                provider.gravity = Gravity.sg;
                onSelected?.call(provider.gravity);
              }
            ),
            CheckboxMenuButton(
              child: Text('Plato °P'),
              value: Gravity.plato == AppLocalizations.of(context)!.gravity,
              onChanged: (value) {
                final provider = Provider.of<ValuesNotifier>(context, listen: false);
                provider.gravity = Gravity.plato;
                onSelected?.call(provider.gravity);
              }
            ),
            CheckboxMenuButton(
              child: Text('Brix °Bx'),
              value: Gravity.brix == AppLocalizations.of(context)!.gravity,
              onChanged: (value) {
                final provider = Provider.of<ValuesNotifier>(context, listen: false);
                provider.gravity = Gravity.brix;
                onSelected?.call(provider.gravity);
              }
            ),
          ]
        ),
        if (publish) MenuItemButton(
          child: Text(AppLocalizations.of(context)!.text('publish_everything')),
          onPressed: () async {
            await Database().publishAll();
            onSelected?.call(Menu.publish);
          }
        ),
        if (filtered) SubmenuButton(
          child: Text(AppLocalizations.of(context)!.text('filtered')),
          menuChildren: <Widget>[
            CheckboxMenuButton(
              child: Text(AppLocalizations.of(context)!.text('archives')),
              value: archived,
              onChanged: (value) {
                onSelected?.call(Menu.archived);
              }
            ),
            CheckboxMenuButton(
              child: Text(AppLocalizations.of(context)!.text('hidden')),
              value: hidden,
              onChanged: (value) {
                onSelected?.call(Menu.hidden);
              }
            ),
          ]
        ),
        if (importLabel != null && importLabel.isNotEmpty) MenuItemButton(
          child: Text(importLabel),
          onPressed: () async {
            onSelected?.call(Menu.imported);
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

class CustomMenuAnchor<Object> extends _CustomMenuAnchor {
  CustomMenuAnchor({Key? key, required BuildContext context, bool publish = false,  bool filtered = false, bool archived = false, bool hidden = false, bool measures = false, String? importLabel, PopupMenuItemSelected? onSelected}) : super(
    key: key,
    context: context,
    publish: publish,
    filtered: filtered,
    archived: archived,
    hidden: hidden,
    measures: measures,
    importLabel: importLabel,
    onSelected: onSelected,
  );
}
