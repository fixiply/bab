import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/models/model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/localized_text.dart';
import 'package:bb/widgets/dialogs/confirm_dialog.dart';

class EditDialog extends StatefulWidget {
  final Model model;
  final String? title;
  final String? okText;
  final String? cancelText;
  EditDialog(this.model, {this.title, this.okText, this.cancelText});

  @override
  State<StatefulWidget> createState() {
    return _EditDialogState();
  }
}

class _EditDialogState extends State<EditDialog> {
  @override
  Widget build(BuildContext context) {
    return ConfirmDialog(
      scrollable: true,
      title: widget.title ?? AppLocalizations.of(context)!.text('edit'),
      ok: AppLocalizations.of(context)!.text('save'),
      content: Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Form(
            child: Column(
              children: _columns()
            )
          ),
        ),
      ),
    );
  }

  List<Widget> _columns() {
    List<Widget> rows = [];
    widget.model.toMap().forEach((key, value) {
      if (key != 'uuid' && key != 'inserted_at' && key != 'updated_at' && key != 'creator' && key != 'status') {
        rows.add(_row(key, value));
      }
    });
    return rows;
  }

  Widget _row(String columnName, dynamic value) {
    return Row(
      children: <Widget>[
        Container(
          width: DeviceHelper.isDesktop ? 130 : 110,
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Text(AppLocalizations.of(context)!.text(columnName))),
        SizedBox(
          width: DeviceHelper.isDesktop ? 400 : 300,
          child: _widget(columnName, value)
        )
      ],
    );
  }

  Widget _widget(String columnName, dynamic value) {
    List<Enums>? enums = widget.model.isEnumType(columnName);
    if (enums != null) {
      return DropdownButton<Enum>(
        value: value != null ? enums.elementAt(value) : null,
        autofocus: true,
        focusColor: Colors.transparent,
        underline: const SizedBox.shrink(),
        icon: const Icon(Icons.arrow_drop_down_sharp),
        isExpanded: true,
        onChanged: (Enum? value) {
        },
        items: enums.map<DropdownMenuItem<Enum>>((Enum e) {
          return DropdownMenuItem<Enum>(
            value: e,
            child: Text(AppLocalizations.of(context)!.text(e.toString().toLowerCase()))
          );
        }).toList()
      );
    }
    String? displayText = value?.toString();
    if (value != null) {
      if (widget.model.isTextType(columnName)) {
        LocalizedText text = LocalizedText.deserialize(value);
        displayText = text.get(AppLocalizations.of(context)!.locale);
      } else if (widget.model.isNumericType(columnName)) {
        displayText = AppLocalizations.of(context)!.numberFormat(value);
      }
    }
    // Holds the regular expression pattern based on the column type.
    RegExp regExp = widget.model.isNumericType(columnName) ? RegExp('[0-9.,]') : RegExp('[a-zA-Z ]');
    return TextFormField(
      initialValue: displayText,
      keyboardType: widget.model.isNumericType(columnName) ? TextInputType.number : TextInputType.text,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(regExp)
      ],
      onChanged: (value) {

      },
    );
  }
}
