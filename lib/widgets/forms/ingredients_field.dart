import 'package:bb/models/fermentable_model.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/tables/fermentables_data_table.dart';
import 'package:bb/controller/tables/hops_data_table.dart';
import 'package:bb/controller/tables/misc_data_table.dart';
import 'package:bb/controller/tables/yeasts_data_table.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/quantity.dart';
import 'package:bb/widgets/form_decoration.dart';

class IngredientsField extends FormField<List<Quantity>> {
  final Ingredient ingredient;
  ReceiptModel? receipt;
  bool allowEditing;
  final void Function(List<Quantity> value)? onChanged;

  IngredientsField({Key? key, required BuildContext context, required this.ingredient, List<Quantity>? data, this.receipt, this.allowEditing = false, this.onChanged}) : super(
      key: key,
      initialValue: data,
      builder: (FormFieldState<List<dynamic>> field) {
        return field.build(field.context);
      }
  );

  @override
  _IngredientsFieldState createState() => _IngredientsFieldState();
}

class _IngredientsFieldState extends FormFieldState<List<Quantity>> {
  final _datatableKey = GlobalKey<FermentablesDataTableState>();

  @override
  IngredientsField get widget => super.widget as IngredientsField;

  @override
  void didChange(List<Quantity>? value) {
    widget.onChanged?.call(value!);
    super.didChange(value);
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: FormDecoration(
        contentPadding: EdgeInsets.all(0.0),
        icon: _icon()
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: _container(),
      )
    );
  }

  Icon _icon() {
    switch(widget.ingredient) {
      case Ingredient.fermentable:
        return Icon(Icons.grain_outlined);
      case Ingredient.hops:
        return Icon(Icons.grass_outlined);
      case Ingredient.yeast:
        return Icon(Icons.bubble_chart_outlined);
      case Ingredient.misc:
        return Icon(Icons.eco_outlined);
    }
  }

  Widget _container() {
    switch(widget.ingredient) {
      case Ingredient.fermentable:
        return FermentablesDataTable(key: _datatableKey,
          data: widget.initialValue,
          title: Text(AppLocalizations.of(context)!.text('fermentables'), style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 16.0)),
          color: FillColor,
          allowEditing: true,
          allowAdding: true,
          showCheckboxColumn: false,
          receipt: widget.receipt,
          onChanged: (List<Quantity>? values) {
            didChange(values);
          }
        );
      case Ingredient.misc:
        return MiscDataTable(key: _datatableKey,
          data: widget.initialValue,
          title: Text(AppLocalizations.of(context)!.text('miscellaneous'), style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 16.0)),
          color: FillColor,
          allowEditing: true,
          allowAdding: true,
          showCheckboxColumn: false,
          receipt: widget.receipt,
          onChanged: (List<Quantity>? values) {
            didChange(values);
          }
        );
      case Ingredient.yeast:
        return YeastsDataTable(key: _datatableKey,
          data: widget.initialValue,
          title: Text(AppLocalizations.of(context)!.text('yeasts'), style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 16.0)),
          color: FillColor,
          allowEditing: true,
          allowAdding: true,
          showCheckboxColumn: false,
          receipt: widget.receipt,
          onChanged: (List<Quantity>? values) {
            didChange(values);
          }
        );
      case Ingredient.hops:
        return HopsDataTable(key: _datatableKey,
          data: widget.initialValue,
          title: Text(AppLocalizations.of(context)!.text('hops'), style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 16.0)),
          color: FillColor,
          allowEditing: true,
          allowAdding: true,
          showCheckboxColumn: false,
          receipt: widget.receipt,
          onChanged: (List<Quantity>? values) {
            didChange(values);
          }
        );
    }
  }
}
