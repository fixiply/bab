import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/tables/fermentables_data_table.dart';
import 'package:bab/controller/tables/fermentation_data_table.dart';
import 'package:bab/models/recipe_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/fermentation.dart';
import 'package:bab/widgets/form_decoration.dart';

class FermentationField extends FormField<List<Fermentation>> {
  RecipeModel? recipe;
  final void Function(List<Fermentation> value)? onChanged;

  FermentationField({Key? key, required BuildContext context, List<Fermentation>? data, this.recipe, this.onChanged}) : super(
      key: key,
      initialValue: data,
      builder: (FormFieldState<List<dynamic>> field) {
        return field.build(field.context);
      }
  );

  @override
  _FermentationFieldState createState() => _FermentationFieldState();
}

class _FermentationFieldState extends FormFieldState<List<Fermentation>> {
  final _datatableKey = GlobalKey<FermentablesDataTableState>();

  @override
  FermentationField get widget => super.widget as FermentationField;

  @override
  void didChange(List<Fermentation>? value) {
    widget.onChanged?.call(value!);
    super.didChange(value);
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: FormDecoration(
        contentPadding: const EdgeInsets.all(0.0),
        icon: const Icon(Icons.cyclone)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: FermentationDataTable(key: _datatableKey,
          data: widget.initialValue,
          title: Text(AppLocalizations.of(context)!.text('fermentation'), style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 16.0)),
          allowEditing: true,
          color: FillColor,
          showCheckboxColumn: false,
          recipe: widget.recipe,
          onChanged: (List<Fermentation>? value) {
            didChange(value);
          }
        )
      )
    );
  }
}
