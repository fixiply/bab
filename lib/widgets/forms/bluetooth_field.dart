import 'package:bab/utils/bluetooth.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/tables/bluetooth_data_table.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/widgets/form_decoration.dart';

class BluetoothField extends FormField<Bluetooth> {
  final void Function(Bluetooth value)? onChanged;

  BluetoothField({Key? key, required BuildContext context, Bluetooth? data, this.onChanged}) : super(
      key: key,
      initialValue: data,
      builder: (FormFieldState<Bluetooth> field) {
        return field.build(field.context);
      }
  );

  @override
  _FermentationFieldState createState() => _FermentationFieldState();
}

class _FermentationFieldState extends FormFieldState<Bluetooth> {
  final _datatableKey = GlobalKey<BluetoothDataTableState>();

  @override
  BluetoothField get widget => super.widget as BluetoothField;

  @override
  void didChange(Bluetooth? value) {
    widget.onChanged?.call(value!);
    super.didChange(value);
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: FormDecoration(
        contentPadding: const EdgeInsets.all(0.0),
        icon: const Icon(Icons.settings_bluetooth_outlined)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: BluetoothDataTable(
          key: _datatableKey,
          bluetooth: widget.initialValue ?? Bluetooth(),
          title: Text(AppLocalizations.of(context)!.text('bluetooth'), style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 16.0)),
          allowEditing: true,
          color: FillColor,
          onChanged: (Bluetooth? value) {
            didChange(value);
          }
        )
      )
    );
  }
}
