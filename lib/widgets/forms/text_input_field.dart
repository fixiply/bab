import 'package:bab/utils/locale_notifier.dart';
import 'package:bab/utils/localized_text.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/widgets/form_decoration.dart';
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_text_input.dart';
import 'package:provider/provider.dart';

class TextInputField extends FormField<dynamic> {
  final String title;
  final void Function(Locale? locale, String? value)? onChanged;
  @override
  final FormFieldValidator<dynamic>? validator;

  TextInputField({Key? key, required BuildContext context, dynamic initialValue, required this.title, this.onChanged, this.validator}) : super(
      key: key,
      initialValue: initialValue,
      builder: (FormFieldState<dynamic> field) {
        return field.build(field.context);
      }
  );

  @override
  _TextInputFieldState createState() => _TextInputFieldState();
}

class _TextInputFieldState extends FormFieldState<dynamic> {

  @override
  TextInputField get widget => super.widget as TextInputField;

  Locale? _locale;
  TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _locale = AppLocalizations.of(context)!.locale;
      _initialize();
    });
    final localeNotifier = Provider.of<LocaleNotifier>(context, listen: false);
    localeNotifier.addListener(() {
      _locale = localeNotifier.locale;
      _initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Locale>? locales = context.findAncestorWidgetOfExactType<MaterialApp>()?.supportedLocales.toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(child: Text(widget.title, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 16.0))),
              SizedBox(
                width: 80,
                child: DropdownButtonFormField<Locale>(
                  value: AppLocalizations.of(context)!.locale,
                  style: DefaultTextStyle.of(context).style.copyWith(overflow: TextOverflow.ellipsis),
                  decoration: FormDecoration(
                    // icon: const Icon(Icons.aspect_ratio),
                    // labelText: AppLocalizations.of(context)!.text('locale'),
                    fillColor: FillColor,
                    filled: true,
                  ),
                  items: locales!.map((Locale locale) {
                    return DropdownMenuItem<Locale>(
                      value: locale,
                      child: Text(LocalizedText.emoji(locale.countryCode!),
                        style: const TextStyle( fontSize: 20, fontFamily: 'Emoji'),
                      )
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _locale = value;
                    });
                    _initialize();
                  }
                )
              )
            ],
          )
        ),
        Flexible(
          child: MarkdownTextInput(
            (String value) => widget.onChanged?.call(_locale, value),
            AppLocalizations.of(context)!.localizedText(widget.initialValue, locale: _locale),
            controller: _textController,
            maxLines: 10,
            actions: MarkdownType.values,
            validators: (value) {
              return null;
            }
          ),
        )
      ]
    );
  }

  _initialize() async {
    _textController.text = AppLocalizations.of(context)!.localizedText(widget.initialValue, locale: _locale);
  }
}
