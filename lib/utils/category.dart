import 'package:flutter/material.dart';

// Internal package
import 'package:bb/models/style_model.dart';
import 'package:bb/utils/localized_text.dart';

class Category {
  dynamic name;
  List<StyleModel>? styles;

  Category({
    this.name,
    this.styles,
  }) {
    styles ??= [];
  }

  String? localizedName(Locale? locale) {
    if (name is LocalizedText) {
      return name.get(locale);
    }
    return name;
  }

  static void populate(List<Category> categories, List<StyleModel> styles, Locale locale) {
    for(StyleModel style in styles) {
      bool found = false;
      Category newModel = Category(name: style.category);
      newModel.styles!.add(style);
      for(Category category in categories) {
        if (category.localizedName(locale) == newModel.localizedName(locale)) {
          category.styles!.add(style);
          found = true;
          break;
        }
      }
      if (!found) {
        categories.add(newModel);
      }
    }
  }
}
