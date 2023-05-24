import 'dart:convert';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/admin/code_editor_page.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/widgets/form_decoration.dart';

class WidgetsField extends FormField<List<String>> {
  final void Function(List<String> value)? onChanged;

  WidgetsField({Key? key, required BuildContext context, List<String>? widgets, this.onChanged}) : super(
      key: key,
      initialValue: widgets,
      builder: (FormFieldState<List<dynamic>> field) {
        return field.build(field.context);
      }
  );

  @override
  _WidgetsFieldState createState() => _WidgetsFieldState();
}

class _WidgetsFieldState extends FormFieldState<List<String>> {
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
              contentPadding: const EdgeInsets.all(0.0),
              icon: const Icon(Icons.widgets_outlined)
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(0.0),
            title:  const Text('Widgets'),
            trailing: IconButton(
                icon:const Icon(Icons.add),
                onPressed: () async {
                  _new();
                }
            )
          )
        ),
        ReorderableListView.builder(
          shrinkWrap: true,
          itemCount: widget.initialValue!.length,
          itemBuilder: (BuildContext context, int index) {
            String data = widget.initialValue![index];
            return Card(
              key: Key(index.toString()),
              child: ListTile(
                title: Text(_title(data)),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
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
      ]
    );
  }

  String _title(String data) {
    var map = json.decode(data);
    return map['type'];
  }

  _new() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CodeEditorPage();
    })).then((value) {
      if (value != false && value != null) {
        widget.initialValue!.add(value);
        didChange(widget.initialValue);
      }
    });
  }

  _edit(int index, String? data) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CodeEditorPage(initialValue: data);
    })).then((value) {
      if (value != false) {
        widget.initialValue![index] = value;
        didChange(widget.initialValue);
      }
    });
  }
}
