import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/tables/fermentables_data_table.dart';
import 'package:bb/controller/tables/mash_data_table.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/mash.dart';
import 'package:bb/widgets/form_decoration.dart';

class MashField extends FormField<List<Mash>> {
  ReceiptModel? receipt;
  final void Function(List<Mash> value)? onChanged;

  MashField({Key? key, required BuildContext context, List<Mash>? data, this.receipt, this.onChanged}) : super(
      key: key,
      initialValue: data,
      builder: (FormFieldState<List<dynamic>> field) {
        return field.build(field.context);
      }
  );

  @override
  _MashFieldState createState() => _MashFieldState();
}

class _MashFieldState extends FormFieldState<List<Mash>> {
  final _datatableKey = GlobalKey<FermentablesDataTableState>();

  @override
  MashField get widget => super.widget as MashField;

  @override
  void didChange(List<Mash>? value) {
    widget.onChanged?.call(value!);
    super.didChange(value);
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: FormDecoration(
        contentPadding: const EdgeInsets.all(0.0),
        icon: const Icon(Icons.water_drop_outlined)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: MashDataTable(key: _datatableKey,
          data: widget.initialValue,
          title: Text(AppLocalizations.of(context)!.text('mash'), style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 16.0)),
          allowEditing: true,
          color: FillColor,
          showCheckboxColumn: false,
          receipt: widget.receipt,
          onChanged: (List<Mash>? value) {
            didChange(value);
          }
        )
      )
    );
  }
}
