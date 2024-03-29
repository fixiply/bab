import 'package:flutter/material.dart';

// Internal package+
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/widgets/duration_picker.dart';
import 'package:bab/widgets/form_decoration.dart';

class DurationField extends FormField<int> {
  final void Function(int? value)? onChanged;
  String? label;
  Widget? icon;
  bool? showIcon;
  @override
  final FormFieldValidator<dynamic>? validator;

  DurationField({Key? key, required int value, this.onChanged, this.label, this.icon, this.showIcon = true, this.validator}) : super(
      key: key,
      initialValue: value,
      builder: (FormFieldState<int> field) {
        return field.build(field.context);
      }
  );

  @override
  _DurationFieldState createState() => _DurationFieldState();
}

class _DurationFieldState extends FormFieldState<int> {
  TextEditingController _textController = TextEditingController();

  @override
  DurationField get widget => super.widget as DurationField;

  @override
  void didChange(int? value) {
    widget.onChanged?.call(value);
    super.didChange(value);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _textController = TextEditingController(text: widget.initialValue?.toString() ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: !DeviceHelper.isDesktop,
      controller: _textController,
      decoration: FormDecoration(
        icon: widget.showIcon == true ? widget.icon ?? const Icon(Icons.timer_outlined) : null,
        labelText: widget.label ?? AppLocalizations.of(context)!.text('duration'),
        suffixText: 'minutes',
        border: InputBorder.none,
        fillColor: FillColor, filled: true
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: widget.validator,
      onEditingComplete: DeviceHelper.isDesktop ? () async {
        didChange(int.tryParse(_textController.text));
      } : null,
      onChanged: DeviceHelper.isDesktop ? (value) async {
        didChange(int.tryParse(value));
      } : null,
      onTap: !DeviceHelper.isDesktop ? () async {
        var duration = await showDurationPicker(
          context: context,
          initialTime: Duration(minutes:  widget.initialValue ?? 0),
          // showOkButton: false,
          // onComplete: (duration, context) {
          //   _textController.text = AppLocalizations.of(context)!.numberFormat(duration.inMinutes) ?? '';
          //   didChange(duration.inMinutes);
          //   Navigator.pop(context);
          // }
        );
        if (duration != null)  {
          _textController.text = AppLocalizations.of(context)!.numberFormat(duration.inMinutes) ?? '';
          didChange(duration.inMinutes);
        }
      } : null,
    );
  }
}
