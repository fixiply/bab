import 'package:bb/utils/edition_notifier.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/utils/locale_notifier.dart';

// External package
import 'package:app_settings/app_settings.dart';
import 'package:provider/provider.dart';

enum Menu {settings, options, publish, archived, hidden}

abstract class _CustomMenuButton extends PopupMenuButton {

  void Function(List<PopupMenuEntry> items)? joints;

  _CustomMenuButton({Key? key, required BuildContext context, bool publish = false, bool filtered = false, bool archived = false, bool measures = false, PopupMenuItemSelected? onSelected, this.joints}) : super(
    key: key,
    padding: EdgeInsets.zero,
    icon: Icon(Icons.more_vert),
    tooltip: MaterialLocalizations.of(context).showMenuTooltip,
    onSelected: (value) async {
      if (value == Menu.settings) {
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
          child: PopupMenuButton(
            padding: EdgeInsets.zero,
            child: Text(AppLocalizations.of(context)!.text('languages')),
            onSelected: (value) async {
              if (value is Locale) {
                Provider.of<LocaleNotifier>(context, listen: false).set(value);
              }
            },
            itemBuilder: (_) {
              return [
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
              ];
            },
          ),
        ),
        if (measures) PopupMenuDivider(height: 5),
        if (measures) PopupMenuItem(
          child: PopupMenuButton(
            padding: EdgeInsets.zero,
            child: Text(AppLocalizations.of(context)!.text('measuring_systems')),
            onSelected: (value) async {
              if (value is Measure) {
                final provider = Provider.of<ValuesNotifier>(context, listen: false);
                provider.measure = value;
                onSelected?.call(value);
              }
            },
            itemBuilder: (_) {
              return [
                CheckedPopupMenuItem(
                  child: Text(AppLocalizations.of(context)!.text('metric')),
                  value: Measure.metric,
                  checked: Measure.metric == AppLocalizations.of(context)!.measure,
                ),
                CheckedPopupMenuItem(
                  child: Text(AppLocalizations.of(context)!.text('imperial')),
                  value: Measure.imperial,
                  checked: Measure.imperial == AppLocalizations.of(context)!.measure,
                ),
              ];
            },
          ),
        ),
        if (measures) PopupMenuDivider(height: 5),
        if (measures) PopupMenuItem(
          child: PopupMenuButton(
            child: Text(AppLocalizations.of(context)!.text('gravity_units')),
            onSelected: (value) async {
              if (value is Gravity) {
                final provider = Provider.of<ValuesNotifier>(context, listen: false);
                provider.gravity = value;
                onSelected?.call(value);
              }
            },
            itemBuilder: (_) {
              return [
                CheckedPopupMenuItem(
                  child: Text('SG'),
                  value: Gravity.sg,
                  checked: Gravity.sg == AppLocalizations.of(context)!.gravity,
                ),
                CheckedPopupMenuItem(
                  child: Text('Plato'),
                  value: Gravity.plato,
                  checked: Gravity.plato == AppLocalizations.of(context)!.gravity,
                ),
                CheckedPopupMenuItem(
                  child: Text('Brix'),
                  value: Gravity.brix,
                  checked: Gravity.brix == AppLocalizations.of(context)!.gravity,
                ),
              ];
            },
          ),
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
  CustomMenuButton({Key? key, required BuildContext context, bool publish = false,  bool filtered = false, bool archived = false, bool measures = false, PopupMenuItemSelected? onSelected, Function(List<PopupMenuEntry> items)? joints}) : super(
    key: key,
    context: context,
    publish: publish,
    filtered: filtered,
    archived: archived,
    measures: measures,
    onSelected: onSelected,
    joints: joints,
  );
}
