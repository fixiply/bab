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
          LocalizedText text =  widget.initialValue is LocalizedText ? widget.initialValue : LocalizedText();
          text.add(AppLocalizations.of(context)!.locale, value);
          widget.initialValue = text.size() > 0 ? text : value;
          didChange(widget.initialValue);
        }),
        decoration: widget.decoration!,
        autovalidateMode: widget.autovalidateMode,
        validator: widget.validator,
      ),
      children: locales.map((locale) {
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Text(LocalizedText.emoji(locale.countryCode!),
            style: TextStyle( fontSize: 20, fontFamily: 'Emoji'),
          ),
          title: TextFormField(
            initialValue: widget.initialValue is LocalizedText ? widget.initialValue.get(locale)  : null,
            textCapitalization: widget.textCapitalization ?? TextCapitalization.sentences,
            onChanged: (value) => setState(() {
              LocalizedText text =  widget.initialValue is LocalizedText ? widget.initialValue : LocalizedText();
              text.add(locale, value);
              widget.initialValue = text.size() > 0 ? text : value;
              didChange(widget.initialValue);
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
