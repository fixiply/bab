import 'package:flutter/material.dart';

// Internal package
import 'package:bb/utils/text_format.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/widgets/dialogs/confirm_dialog.dart';

// External package
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class TextFormatField extends FormField<TextFormat> {
  final TextFormat? initialValue;
  InputDecoration? decoration;
  final void Function(TextFormat? value)? onChanged;
  final FormFieldValidator<TextFormat>? validator;

  TextFormatField({Key? key, required BuildContext context, this.initialValue, this.decoration, this.onChanged, this.validator}) : super(
    key: key,
    initialValue: initialValue ?? TextFormat(),
    builder: (FormFieldState<TextFormat> field) {
      return field.build(field.context);
    }
  );

  @override
  _TextFormatFieldState createState() => _TextFormatFieldState();
}

class _TextFormatFieldState extends FormFieldState<TextFormat> {
  final GlobalKey<FormFieldState> _key = GlobalKey<FormFieldState>();

  @override
  TextFormatField get widget => super.widget as TextFormatField;

  @override
  void didChange(TextFormat? value) {
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
        icon:Icon(Icons.text_format),
        onPressed: () async {
          _showDialog(widget.initialValue);
        }
      )
    );
  }

  _showDialog(TextFormat? text) async {
    text ??= TextFormat();
    List<bool> selected = [text.bold ?? false, text.italic ?? false, text.underline ?? false];
    bool confirm = await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ConfirmDialog(
              title: AppLocalizations.of(context)!.text('text_style'),
              content: Container(
                height: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('${AppLocalizations.of(context)!.text('size')} :'),
                        SizedBox(width: 10),
                        DropdownButton<double>(
                          value: text!.size,
                          onChanged: (double? value) {
                            setState(() {
                              text!.size = value;
                            });
                          },
                          items: List<int>.generate(40, (i) => i + 1).map<
                              DropdownMenuItem<double>>((int value) {
                            return DropdownMenuItem<double>(
                              value: value.toDouble(),
                              child: Text(value.toString()),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    ToggleButtons(
                      children: <Widget>[
                        Icon(Icons.format_bold),
                        Icon(Icons.format_italic),
                        Icon(Icons.format_underline),
                      ],
                      onPressed: (int index) {
                        setState(() {
                          selected[index] = !selected[index];
                        });
                      },
                      isSelected: selected,
                    ),
                    Row(
                      children: [
                        Text('${AppLocalizations.of(context)!.text('color')} :'),
                        SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(padding: EdgeInsets.zero, backgroundColor: Color(text.color!)),
                          onPressed: () async {
                            int? pickerColor = text!.color;
                            bool confirm = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ConfirmDialog(
                                  title: AppLocalizations.of(context)!.text('pick_a_color'),
                                  content: SingleChildScrollView(
                                    child: ColorPicker(
                                      pickerColor: Color(pickerColor!),
                                      hexInputBar: true,
                                      onColorChanged: (color) {
                                        pickerColor = color.value;
                                      },
                                    ),
                                  ),
                                );
                              }
                            );
                            if (confirm) {
                              setState(() {
                                text!.color = pickerColor;
                              });
                            }
                          },
                          child: const Text(''),
                        )
                      ],
                    ),
                  ],
                )
              )
            );
          }
        );
      }
    );
    if (confirm) {
      text.bold = selected[0];
      text.italic = selected[1];
      text.underline = selected[2];
      didChange(text);
    }
  }
}
