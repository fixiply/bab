import 'package:flutter/material.dart';

// Internal package
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/localized_text.dart';
import 'package:bb/utils/text_format.dart';
import 'package:bb/widgets/form_decoration.dart';

// External package

class LocalizedTextField extends FormField<dynamic> {
  dynamic? initialValue;
  InputDecoration? decoration;
  TextCapitalization? textCapitalization;
  AutovalidateMode autovalidateMode;
  final void Function(dynamic? value)? onChanged;
  final FormFieldValidator<dynamic>? validator;

  LocalizedTextField({Key? key, required BuildContext context, this.initialValue, this.decoration, this.textCapitalization, required this.autovalidateMode, this.onChanged, this.validator}) : super(
    key: key,
    initialValue: initialValue ?? TextFormat(),
    builder: (FormFieldState<dynamic> field) {
      return field.build(field.context);
    }
  );

  @override
  _LocalizedTextFieldState createState() => _LocalizedTextFieldState();
}

class _LocalizedTextFieldState extends FormFieldState<dynamic> {
  final GlobalKey<FormFieldState> _key = GlobalKey<FormFieldState>();

  @override
  LocalizedTextField get widget => super.widget as LocalizedTextField;

  @override
  void didChange(dynamic? value) {
    widget.onChanged?.call(value);
    super.didChange(value);
  }

  @override
  Widget build(BuildContext context) {
    List<Locale>? locales = context.findAncestorWidgetOfExactType<MaterialApp>()?.supportedLocales.toList();
    locales!.remove(AppLocalizations.of(context)!.locale);
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: TextFormField(
        initialValue: widget.initialValue != null ? widget.initialValue.toString() : null,
        textCapitalization: widget.textCapitalization ?? TextCapitalization.sentences,
        onChanged: (value) => setState(() {
          if (widget.initialValue is String) {
            widget.initialValue = value;
          } if (widget.initialValue is LocalizedText) {
            widget.initialValue.map[AppLocalizations.of(context)!.locale.toString()] = value;
          }
          didChange(widget.initialValue);
        }),
        decoration: widget.decoration!,
        autovalidateMode: widget.autovalidateMode,
        validator: widget.validator,
      ),
      children: locales.map((locale) {
        LocalizedText localizedTextModel = LocalizedText();
        if (widget.initialValue is LocalizedText) {
          localizedTextModel.map!.addAll(widget.initialValue.map);
        }
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Text(LocalizedText.emoji(locale.countryCode!),
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Emoji',
            ),
          ),
          title: TextFormField(
            initialValue: localizedTextModel.map![locale.toString()],
            textCapitalization: widget.textCapitalization ?? TextCapitalization.sentences,
            onChanged: (value) => setState(() {
              if (widget.initialValue is String) {
                localizedTextModel.add(AppLocalizations.of(context)!.locale, widget.initialValue);
              }
              localizedTextModel.add(locale, value);
              didChange(localizedTextModel);
            }),
            decoration: FormDecoration(
              // labelText: locale.toString(),
              border: InputBorder.none,
              fillColor: FillColor, filled: true
            ),
          ),
        );
      }).toList(),
    );
  }
}
