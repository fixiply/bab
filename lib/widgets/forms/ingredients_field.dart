import 'package:bb/models/fermentable_model.dart';
import 'package:bb/models/hop_model.dart';
import 'package:bb/models/misc_model.dart';
import 'package:bb/models/yeast_model.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/tables/fermentables_data_table.dart';
import 'package:bb/controller/tables/hops_data_table.dart';
import 'package:bb/controller/tables/misc_data_table.dart';
import 'package:bb/controller/tables/yeasts_data_table.dart';
import 'package:bb/models/model.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/widgets/form_decoration.dart';

class IngredientsField extends FormField<List<Model>> {
  final Ingredient ingredient;
  ReceiptModel? receipt;
  bool allowEditing;
  final void Function(List<Model> value)? onChanged;

  IngredientsField({Key? key, required BuildContext context, required this.ingredient, this.receipt, this.allowEditing = false, this.onChanged}) : super(
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
          future: widget.receipt!.getFermentables(),
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
                receipt: widget.receipt,
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
          future: widget.receipt!.getMisc(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return MiscDataTable(key: _datatableKey,
                data: snapshot.data,
                title: Text(AppLocalizations.of(context)!.text('miscellaneous'), style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 16.0)),
                color: FillColor,
                allowEditing: true,
                allowAdding: true,
                showCheckboxColumn: false,
                receipt: widget.receipt,
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
          future: widget.receipt!.getYeasts(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return YeastsDataTable(key: _datatableKey,
                data: snapshot.data,
                title: Text(AppLocalizations.of(context)!.text('yeasts'), style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 16.0)),
                color: FillColor,
                allowEditing: true,
                allowAdding: true,
                showCheckboxColumn: false,
                receipt: widget.receipt,
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
          future: widget.receipt!.gethops(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return HopsDataTable(key: _datatableKey,
                data: snapshot.data,
                title: Text(AppLocalizations.of(context)!.text('hops'), style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 16.0)),
                color: FillColor,
                allowEditing: true,
                allowAdding: true,
                showCheckboxColumn: false,
                receipt: widget.receipt,
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
