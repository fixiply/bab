import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/color_units.dart';
import 'package:bb/widgets/form_decoration.dart';

class ColorField extends FormField<double> {
  final void Function(double? value)? onChanged;
  final void Function()? onEditingComplete;
  String? hintText;
  bool showIcon;
  Widget? icon;

  ColorField({Key? key, required BuildContext context, double? value, this.onChanged, this.onEditingComplete, this.hintText, this.showIcon = true, this.icon}) : super(
    key: key,
    initialValue: value,
    builder: (FormFieldState<double> field) {
      return field.build(field.context);
    }
  );

  @override
  _ColorFieldState createState() => _ColorFieldState();
}

class _ColorFieldState extends FormFieldState<double> {
  @override
  ColorField get widget => super.widget as ColorField;

  late TextEditingController _srmTextController;
  late TextEditingController _ebcTextController;

  @override
  void initState() {
    super.initState();
    _srmTextController = TextEditingController(text: widget.initialValue != null ? widget.initialValue.toString() : '');
    _ebcTextController = TextEditingController();
  }

  @override
  void didChange(double? value) {
    widget.onChanged?.call(value);
    super.didChange(value);
  }

  @override
  Widget build(BuildContext context) {
    return  InputDecorator(
      decoration: FormDecoration(
        prefixIcon: widget.icon ?? (widget.showIcon ? Icon(Icons.color_lens_outlined) : null)
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _srmTextController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
              ],
              onEditingComplete: widget.onEditingComplete,
              onChanged: (value) => setState(() {
                _ebcTextController.text = ColorUnits.toEBC(double.tryParse(value)!).toString();
                didChange(double.tryParse(value));
              }),
              decoration: FormDecoration(
                labelText: AppLocalizations.of(context)!.text('color'),
                border: InputBorder.none,
                fillColor: FillColor, filled: true
              ),
            ),
          ),
          SizedBox(width: 4),
          SizedBox(
            width: 80,
            child: DropdownButtonFormField<String>(
              value: 'EBC',
              items: [
                DropdownMenuItem<String>(
                  value: 'EBC',
                  child: Text('EBC', style: TextStyle(fontSize: 13))
                ),
                DropdownMenuItem<String>(
                  value: 'SRM',
                  child: Text('SRM', style: TextStyle(fontSize: 13))
                ),
              ],
              onChanged: (value) =>
                setState(() {
                }
              ),
            )
          )
        ]
      )
    );
  }
}
