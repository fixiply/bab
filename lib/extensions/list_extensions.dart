import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/stepper_page.dart';
import 'package:bab/utils/app_localizations.dart';

extension ListExtension on List {
  void set(Iterable<dynamic> iterable, BuildContext context) {
    for(dynamic item in iterable) {
      if (item.amount != null) {
        String? text = AppLocalizations.of(context)!.measurementFormat(item.amount, item.measurement);
        if (text != null) {
          Ingredient? boil = this.cast<Ingredient?>().firstWhere((e) => e!.minutes == item.duration, orElse: () => null);
          if (boil != null) {
            boil.map![AppLocalizations.of(context)!.localizedText(item.name)] = text;
          } else {
            add(Ingredient(
              minutes: item.duration!,
              map: { AppLocalizations.of(context)!.localizedText(item.name): text},
            ));
          }
        }
      }
    }
  }

  bool isExpanded(int n) {
    for (Map element in this) {
      if (element.containsKey(n)) {
        return element[n];
      }
    }
    return false;
  }

  void update(int n, bool b) {
    bool found = false;
    for (Map element in this) {
      if (element.containsKey(n)) {
        element[n] = b;
        found = true;
      }
    }
    if (!found) {
      add({n: b});
    }
  }
}