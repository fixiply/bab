import 'package:flutter/material.dart';

// Internal package
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/utils/locale_notifier.dart';

// External package
import 'package:app_settings/app_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

enum Menu {settings, options, publish, archived, hidden}

// Authentification
final _auth = FirebaseAuth.instance;

abstract class _CustomMenuButton extends PopupMenuButton {

  void Function(List<PopupMenuEntry> items)? joints;

  _CustomMenuButton({Key? key, required BuildContext context, bool publish = false, bool filtered = false, bool archived = false, bool units = false, PopupMenuItemSelected? onSelected, this.joints}) : super(
    key: key,
    padding: EdgeInsets.zero,
    icon: Icon(Icons.more_vert),
    tooltip: MaterialLocalizations.of(context).showMenuTooltip,
    onSelected: (value) async {
      if (value is Locale) {
        Provider.of<LocaleNotifier>(context, listen: false).set(value);
      } else  if (value == Menu.settings) {
        AppSettings.openNotificationSettings();
      } else if (value == Menu.publish) {
        await Database().publishAll();
        onSelected?.call(value);
     } else {
        onSelected?.call(value);
      }
    },
    itemBuilder: (BuildContext context) {
      List<PopupMenuEntry> items = <PopupMenuEntry>[
        if (!DeviceHelper.isDesktop) PopupMenuItem(
          value: Menu.settings,
          child: Text(AppLocalizations.of(context)!.text('alert_settings'))
        ),
        if (!DeviceHelper.isDesktop) PopupMenuDivider(height: 5),
        PopupMenuItem(
          enabled: false,
          value: null,
          child: Text(AppLocalizations.of(context)!.text('language')),
        ),
        CheckedPopupMenuItem(
          child: Text(AppLocalizations.of(context)!.text('english')),
          value: const Locale('en', 'US'),
          checked: const Locale('en', 'US') == AppLocalizations.of(context)!.locale,
        ),
        CheckedPopupMenuItem(
          child: Text(AppLocalizations.of(context)!.text('french')),
          value: const Locale('fr', 'FR'),
          checked: const Locale('fr', 'FR') == AppLocalizations.of(context)!.locale,
        ),
        if (units) PopupMenuDivider(height: 5),
        if (units) PopupMenuItem(
          enabled: false,
          value: null,
          child: Text(AppLocalizations.of(context)!.text('unit_type')),
        ),
        if (units) CheckedPopupMenuItem(
          child: Text(AppLocalizations.of(context)!.text('metric')),
          value: Unit.metric,
          checked: Unit.metric == AppLocalizations.of(context)!.unit,
        ),
        if (units) CheckedPopupMenuItem(
          child: Text(AppLocalizations.of(context)!.text('imperial')),
          value: Unit.imperial,
          checked: Unit.imperial == AppLocalizations.of(context)!.unit,
        ),
        if (publish) PopupMenuDivider(height: 5),
        if (publish) PopupMenuItem(
          child: Text(AppLocalizations.of(context)!.text('publish_everything')),
          value: Menu.publish,
        ),
        if (filtered) PopupMenuDivider(height: 5),
        if (filtered) PopupMenuItem(
          enabled: false,
          value: null,
          child: Text(AppLocalizations.of(context)!.text('filtered')),
        ),
        if (filtered) CheckedPopupMenuItem(
          child: Text(AppLocalizations.of(context)!.text('archives')),
          value: Menu.archived,
          checked: archived,
        ),
        if (filtered) CheckedPopupMenuItem(
          child: Text(AppLocalizations.of(context)!.text('hidden')),
          value: Menu.hidden,
          checked: archived,
        ),
      ];
      if (joints != null) joints(items);
      return items;
    }
  );
}

class CustomMenuButton<Object> extends _CustomMenuButton {
  CustomMenuButton({Key? key, required BuildContext context, bool publish = false,  bool filtered = false, bool archived = false, bool units = false, PopupMenuItemSelected? onSelected, Function(List<PopupMenuEntry> items)? joints}) : super(
    key: key,
    context: context,
    publish: publish,
    filtered: filtered,
    archived: archived,
    units: units,
    onSelected: onSelected,
    joints: joints,
  );
}
