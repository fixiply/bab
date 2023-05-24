import 'dart:convert';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/admin/code_editor_page.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/widgets/form_decoration.dart';

// External package

class CodeEditorField extends FormField<String> {
  @override
  String? initialValue;
  String? title;
  final void Function(String? value)? onChanged;
  @override
  final FormFieldValidator<String>? validator;

  CodeEditorField({Key? key, required BuildContext context, this.initialValue, this.title, this.onChanged, this.validator}) : super(
    key: key,
    initialValue: initialValue,
    builder: (FormFieldState<String> field) {
      return field.build(field.context);
    }
  );

  @override
  _CodeEditorFieldState createState() => _CodeEditorFieldState();
}

class _CodeEditorFieldState extends FormFieldState<String> {
  @override
  CodeEditorField get widget => super.widget as CodeEditorField;

  @override
  void didChange(String? value) {
    widget.onChanged?.call(value);
    super.didChange(value);
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
        decoration: FormDecoration(
        contentPadding: const EdgeInsets.all(0.0),
        icon: const Icon(Icons.code)
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          widget.initialValue != null ? json.encode(widget.initialValue!) : widget.title ?? AppLocalizations.of(context)!.text('code_editor'),
          maxLines: 1,
          style: const TextStyle(overflow: TextOverflow.ellipsis)
        ),
        trailing: IconButton(
          icon:const Icon(Icons.chevron_right),
          onPressed: () async {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return CodeEditorPage(initialValue: widget.initialValue);
            })).then((value) {
              if (value != false) {
                didChange(value);
              }
            });
          }
        )
      )
    );
  }
}
