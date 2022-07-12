import 'package:flutter/material.dart';

// Internal package
import 'package:bb/models/text_model.dart';
import 'package:bb/utils/app_localizations.dart';

// External package
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class TextStyleField extends FormField<TextModel> {
  final TextModel? initialValue;
  InputDecoration? decoration;
  final void Function(TextModel? value)? onChanged;
  final FormFieldValidator<TextModel>? validator;

  TextStyleField({Key? key, required BuildContext context, this.initialValue, this.decoration, this.onChanged, this.validator}) : super(
    key: key,
    initialValue: initialValue ?? TextModel(),
    builder: (FormFieldState<TextModel> field) {
      return field.build(field.context);
    }
  );

  @override
  _TextStyleFieldState createState() => _TextStyleFieldState();
}

class _TextStyleFieldState extends FormFieldState<TextModel> {
  final GlobalKey<FormFieldState> _key = GlobalKey<FormFieldState>();

  @override
  TextStyleField get widget => super.widget as TextStyleField;

  @override
  void didChange(TextModel? value) {
    widget.onChanged?.call(value);
    super.didChange(value);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: TextFormField(
        initialValue: widget.initialValue != null ? widget.initialValue!.text : null,
        textCapitalization: TextCapitalization.sentences,
        onChanged: (value) => setState(() {
          widget.initialValue!.text = value;
          didChange(widget.initialValue);
        }),
        decoration: widget.decoration!
      ),
      trailing: IconButton(
        icon:Icon(Icons.format_size),
        onPressed: () async {
          _showDialog();
        }
      )
    );
  }

  _showDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Style'),
          content: Container(
            height: 160,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Size:'),
                    SizedBox(width: 10),
                    DropdownButton<double>(
                      value: widget.initialValue != null ? widget.initialValue!.size : 14,
                      onChanged: (double? value) {
                        widget.initialValue!.size = value;
                        didChange(widget.initialValue);
                      },
                      items: List<int>.generate(40, (i) => i + 1).map<DropdownMenuItem<double>>((int value) {
                        return DropdownMenuItem<double>(
                          value: value.toDouble(),
                          child: Text(value.toString()),
                        );
                      }).toList(),
                    )
                  ],
                ),
                Row(
                  children: [
                    Text('Color:'),
                    SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: EdgeInsets.zero, primary: _color()),
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Pick a color!'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: _color(),
                                  onColorChanged: (color) {
                                    widget.initialValue!.color = color.value;
                                    didChange(widget.initialValue);
                                  },
                                ),
                              ),
                            );
                          }
                        );
                      },
                      child: const Text(''),
                    )
                  ],
                ),
                TextButton(
                  child: Text(AppLocalizations.of(context)!.text('close')),
                  style: TextButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  onPressed: () => Navigator.of(context).pop()
                )
              ],
            )
          )
        );
      }
    );
  }

  _color() {
    return widget.initialValue != null  && widget.initialValue!.color != null ? Color(widget.initialValue!.color!) : Colors.black;
  }
}
