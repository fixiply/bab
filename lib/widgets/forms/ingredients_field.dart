import 'package:bab/controller/tables/fields/amount_field.dart';
import 'package:bab/models/fermentable_model.dart';
import 'package:bab/models/hop_model.dart';
import 'package:bab/models/misc_model.dart';
import 'package:bab/models/yeast_model.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/tables/fermentables_data_table.dart';
import 'package:bab/controller/tables/hops_data_table.dart';
import 'package:bab/controller/tables/misc_data_table.dart';
import 'package:bab/controller/tables/yeasts_data_table.dart';
import 'package:bab/controller/tables/fields/amount_field.dart' as amount;
import 'package:bab/models/model.dart';
import 'package:bab/models/recipe_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/widgets/form_decoration.dart';

class IngredientsField extends FormField<List<Model>> {
  final Ingredient ingredient;
  RecipeModel? recipe;
  bool allowEditing;
  final void Function(List<Model> value)? onChanged;

  IngredientsField({Key? key, required BuildContext context, required this.ingredient, this.recipe, this.allowEditing = false, this.onChanged}) : super(
      key: key,
      builder: (FormFieldState<List<dynamic>> field) {
        return field.build(field.context);
      }
  );

  @override
  _IngredientsFieldState createState() => _IngredientsFieldState();
}

class _IngredientsFieldState extends FormFieldState<List<Model>> {
  final _datatableKey = GlobalKey<FermentablesDataTableState>();

  @override
  IngredientsField get widget => super.widget as IngredientsField;

  @override
  void didChange(List<Model>? value) {
    widget.onChanged?.call(value!);
    super.didChange(value);
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: FormDecoration(
        contentPadding: const EdgeInsets.all(0.0),
        icon: _icon()
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: _container(),
      )
    );
  }

  Icon _icon() {
    switch(widget.ingredient) {
      case Ingredient.fermentable:
        return const Icon(Icons.grain_outlined);
      case Ingredient.hops:
        return const Icon(Icons.grass_outlined);
      case Ingredient.yeast:
        return const Icon(Icons.bubble_chart_outlined);
      case Ingredient.misc:
        return const Icon(Icons.eco_outlined);
    }
  }

  Widget _container() {
    switch(widget.ingredient) {
      case Ingredient.fermentable:
        return FutureBuilder<List<FermentableModel>>(
          future: widget.recipe!.getFermentables(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return FermentablesDataTable(
                key: _datatableKey,
                data:  snapshot.data,
                title: Text(AppLocalizations.of(context)!.text('fermentables'), style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 16.0)),
                color: FillColor,
                allowEditing: true,
                allowAdding: true,
                showCheckboxColumn: false,
                showAction: true,
                recipe: widget.recipe,
                onChanged: (List<FermentableModel>? values) {
                  didChange(values);
                }
              );
            }
            return Container();
          }
        );
      case Ingredient.misc:
        return FutureBuilder<List<MiscModel>>(
          future: widget.recipe!.getMisc(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return MiscDataTable(key: _datatableKey,
                data: snapshot.data,
                title: Text(AppLocalizations.of(context)!.text('miscellaneous'), style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 16.0)),
                color: FillColor,
                allowEditing: true,
                allowAdding: true,
                showCheckboxColumn: false,
                showAction: true,
                recipe: widget.recipe,
                onChanged: (List<MiscModel>? values) {
                  didChange(values);
                }
              );
            }
            return Container();
          }
        );
      case Ingredient.yeast:
        return FutureBuilder<List<YeastModel>>(
          future: widget.recipe!.getYeasts(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return YeastsDataTable(key: _datatableKey,
                data: snapshot.data,
                title: Text(AppLocalizations.of(context)!.text('yeasts'), style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 16.0)),
                color: FillColor,
                allowEditing: true,
                allowAdding: true,
                showCheckboxColumn: false,
                showAction: true,
                recipe: widget.recipe,
                onChanged: (List<YeastModel>? values) {
                  didChange(values);
                }
              );
            }
            return Container();
          }
        );
      case Ingredient.hops:
        return FutureBuilder<List<HopModel>>(
          future: widget.recipe!.gethops(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return HopsDataTable(key: _datatableKey,
                data: snapshot.data,
                title: Text(AppLocalizations.of(context)!.text('hops'), style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 16.0)),
                color: FillColor,
                allowEditing: true,
                allowAdding: true,
                showCheckboxColumn: false,
                showAction: true,
                recipe: widget.recipe,
                onChanged: (List<HopModel>? values) {
                  didChange(values);
                }
              );
            }
            return Container();
          }
        );
    }
  }
}
