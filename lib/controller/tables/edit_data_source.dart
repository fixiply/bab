import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';

// External package
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';

// External package
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

abstract class EditDataSource extends DataGridSource {
  dynamic newCellValue;
  BuildContext context;
  bool showCheckboxColumn;
  bool showQuantity;
  EditDataSource(this.context, {this.showCheckboxColumn = false, this.showQuantity = false});

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  TextEditingController editingController = TextEditingController();

  bool isNumericType(GridColumn column) {
    return false;
  }

  List<Enums>? isEnumType(GridColumn column) {
    return null;
  }

  String? suffixText(GridColumn column) {
    return null;
  }

  dynamic? getValue(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex, GridColumn column) {
    return dataGridRow.getCells().firstWhere((DataGridCell dataGridCell) => dataGridCell.columnName == column.columnName).value;
  }

  @override
  Widget? buildEditWidget(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex, GridColumn column, CellSubmit submitCell) {
    // Text going to display on editable widget
    var value = getValue(dataGridRow, rowColumnIndex, column);
    newCellValue = value;
    if (value is Enums) {
      return dropDownWidget(value, submitCell);
    }
    return textFieldWidget(value?.toString() ?? '', column, submitCell);
  }

  Widget textFieldWidget(String displayText, GridColumn column, CellSubmit submitCell) {
    RegExp regExp = isNumericType(column) ? RegExp('[0-9.,]') : RegExp('[a-zA-Z ]');
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: isNumericType(column) ? Alignment.centerRight : Alignment.centerLeft,
      child: TextField(
        autofocus: true,
        controller: editingController..text = displayText,
        textAlign: isNumericType(column) ? TextAlign.right : TextAlign.left,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 16.0),
          suffixText: suffixText(column)
        ),
        keyboardType: isNumericType(column) ? TextInputType.number : TextInputType.text,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(regExp)
        ],
        onChanged: (String value) {
          if (value.isNotEmpty) {
            if (isNumericType(column)) {
              try {
                newCellValue = NumberFormat.decimalPattern(AppLocalizations.of(context)!.locale.toString()).parse(value);
              } catch(e) {
                newCellValue = double.tryParse(value);
              }
            } else {
              newCellValue = value;
            }
          } else {
            newCellValue = null;
          }
        },
        onSubmitted: (String value) {
          // In Mobile Platform.
          // Call [CellSubmit] callback to fire the canSubmitCell and
          // onCellSubmit to commit the new value in single place.
          submitCell();
        },
      ),
    );
  }

  Widget dropDownWidget(Enums value, CellSubmit submitCell) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.centerLeft,
      child: DropdownButton<Enum>(
        value: value,
        autofocus: true,
        focusColor: Colors.transparent,
        underline: const SizedBox.shrink(),
        icon: const Icon(Icons.arrow_drop_down_sharp),
        isExpanded: true,
        onChanged: (Enum? value) {
          newCellValue = value;
          /// Call [CellSubmit] callback to fire the canSubmitCell and
          /// onCellSubmit to commit the new value in single place.
          submitCell();
        },
        items: value.enums.map<DropdownMenuItem<Enum>>((Enum e) {
          return DropdownMenuItem<Enum>(
            value: e,
            child: Text(AppLocalizations.of(context)!.text(e.toString().toLowerCase()))
          );
        }).toList()
      ),
    );
  }

  Widget typeHeadWidget(Enums value, CellSubmit submitCell) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.centerLeft,
      child: TypeAheadField(
        itemBuilder: (context, String suggestion) {
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              suggestion,
            ),
          );
        },
        suggestionsCallback: (pattern) {
          List<String> matches = value.enums.map((Enum e) {
            return AppLocalizations.of(context)!.text(e.toString().toLowerCase());
          }).toList();
          matches.retainWhere((s) => s.toLowerCase().contains(pattern.toLowerCase()));
          return Future.delayed(
            Duration(seconds: 1), () => matches,
          );
        },
        onSuggestionSelected: (String value) {
          newCellValue = value;
          /// Call [CellSubmit] callback to fire the canSubmitCell and
          /// onCellSubmit to commit the new value in single place.
          submitCell();
        },
      ),
    );
  }

  DataGridCell? getCell(DataGridRow row, String columnName) {
    for(DataGridCell cell in  row.getCells()) {
      if (cell.columnName == columnName) {
        return cell;
      }
    }
  }

  void updateDataSource() {
    notifyListeners();
  }
}