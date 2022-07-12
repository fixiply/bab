import 'dart:convert';

import 'package:bb/widgets/dialogs/text_input_dialog.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/widgets/form_decoration.dart';

class WidgetsField extends FormField<List<String>> {
  final int? maxLines;
  final void Function(List<String> value)? onChanged;

  WidgetsField({Key? key, required BuildContext context, List<String>? widgets, this.onChanged, this.maxLines}) : super(
      key: key,
      initialValue: widgets,
      builder: (FormFieldState<List<dynamic>> field) {
        return field.build(field.context);
      }
  );

  @override
  _ProductFieldState createState() => _ProductFieldState();
}

class _ProductFieldState extends FormFieldState<List<String>> {
  @override
  WidgetsField get widget => super.widget as WidgetsField;

  @override
  void didChange(List<String>? value) {
    widget.onChanged?.call(value!);
    super.didChange(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        InputDecorator(
          decoration: FormDecoration(
              contentPadding: EdgeInsets.all(0.0),
              icon: Icon(Icons.widgets_outlined)
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(0.0),
            title:  Text('Widgets'),
            trailing: IconButton(
                icon:Icon(Icons.add),
                onPressed: () async {
                  _new();
                }
            )
          )
        ),
        Container(
          child: ReorderableListView.builder(
            shrinkWrap: true,
            itemCount: widget.initialValue!.length,
            itemBuilder: (BuildContext context, int index) {
              String data = widget.initialValue![index];
              return Card(
                key: Key(index.toString()),
                child: ListTile(
                  title: Text(data != null ? json.encode(data) : ''),
                  trailing: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert),
                    tooltip: AppLocalizations.of(context)!.text('options'),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _edit(index, data);
                      } else if (value == 'remove') {
                        widget.initialValue!.removeAt(index);
                        didChange(widget.initialValue);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(AppLocalizations.of(context)!.text('edit')),
                      ),
                      PopupMenuItem(
                        value: 'remove',
                        child: Text(AppLocalizations.of(context)!.text('remove')),
                      ),
                    ]
                  )
                )
              );
            },
            onReorder: (int oldIndex, int newIndex) {
              List<String>? values = widget.initialValue;
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final dynamic item = values!.removeAt(oldIndex);
              values.insert(newIndex, item);
              didChange(values);
            }
          )
        )
      ]
    );
  }

  _new() async {
    dynamic? text = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return TextInputDialog(
              initialValue: null,
              maxLines: widget.maxLines
          );
        }
    );
    if (text != false) {
      widget.initialValue!.add(text);
      didChange(widget.initialValue);
    }
  }

  _edit(int index, String? data) async {
    dynamic? text = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return TextInputDialog(
              initialValue: data,
              maxLines: widget.maxLines
          );
        }
    );
    if (text != false) {
      widget.initialValue![index] = text;
      didChange(widget.initialValue);
    }
  }

  _showDialog(String? data) async {
    dynamic? text = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return TextInputDialog(
              initialValue: data,
              maxLines: widget.maxLines
          );
        }
    );
    if (text != false) {
      didChange(text);
    }
  }
}
