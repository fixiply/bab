import 'package:flutter/material.dart';

// Internal package
import 'package:bab/helpers/color_helper.dart';

// External package
import 'package:flex_color_picker/flex_color_picker.dart';

class ColorField extends FormField<String> {
  final void Function(String? value)? onChanged;
  @override
  final FormFieldValidator<dynamic>? validator;

  ColorField({Key? key, required BuildContext context, String? initialValue, this.onChanged, this.validator}) : super(
      key: key,
      initialValue: initialValue,
      builder: (FormFieldState<String> field) {
        return field.build(field.context);
      }
  );

  @override
  _BeerStyleFieldState createState() => _BeerStyleFieldState();
}

class _BeerStyleFieldState extends FormFieldState<String> {
  @override
  ColorField get widget => super.widget as ColorField;

  @override
  void didChange(String? value) {
    widget.onChanged?.call(value);
    super.didChange(value);
  }

  @override
  Widget build(BuildContext context) {
    return ColorIndicator(
      width: 32,
      height: 32,
      borderRadius: 16,
      color: ColorHelper.fromHex(widget.initialValue!) ?? Colors.white,
      onSelect: () async {
        // Wait for the dialog to return color selection result.
        final Color newColor = await showColorPickerDialog(
          // The dialog needs a context, we pass it in.
          context,
          // We use the dialogSelectColor, as its starting color.
          ColorHelper.fromHex(widget.initialValue!) ?? Colors.white,
          title: Text('ColorPicker', style: Theme.of(context).textTheme.titleLarge),
          width: 40,
          height: 40,
          spacing: 0,
          runSpacing: 0,
          borderRadius: 0,
          wheelDiameter: 165,
          enableOpacity: true,
          showColorCode: true,
          colorCodeHasColor: true,
          pickersEnabled: <ColorPickerType, bool>{
            ColorPickerType.wheel: true,
          },
          copyPasteBehavior: const ColorPickerCopyPasteBehavior(
            copyButton: true,
            pasteButton: true,
            longPressMenu: true,
          ),
          actionButtons: const ColorPickerActionButtons(
            okButton: true,
            closeButton: true,
            dialogActionButtons: false,
          ),
          constraints: const BoxConstraints(minHeight: 480, minWidth: 320, maxWidth: 320),
        );
        didChange(ColorHelper.toHex(newColor));
      }
    );
  }
}
