import 'package:bab/utils/localized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bab/extensions/iterate_extensions.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';

// External package
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

abstract class EditDataSource extends DataGridSource {
  dynamic newCellValue;
  BuildContext context;
  bool? showCheckboxColumn;
  bool? showQuantity;
  bool? showAction;
  EditDataSource(this.context, {this.showCheckboxColumn = false, this.showQuantity = false, this.showAction = false});

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  TextEditingController editingController = TextEditingController();

  bool isNumericType(String columnName) {
    return false;
  }

  bool isDateTimeType(String columnName) {
    return false;
  }

  bool isDateType(String columnName) {
    return false;
  }

  List<Enums>? isEnumType(String columnName) {
    return null;
  }

  String? suffixText(String columnName) {
    return null;
  }

  Widget tooltipText(String? text) {
    if (text != null) {
      return Tooltip(message: text, child: Text(text, overflow: TextOverflow.ellipsis));
    }
    return Container();
  }

  dynamic getValue(DataGridRow dataGridRow, String columnName) {
    return dataGridRow.getCells().firstWhere((DataGridCell dataGridCell) => dataGridCell.columnName == columnName).value;
  }

  @override
  Widget? buildEditWidget(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex, GridColumn column, CellSubmit submitCell) {
    // Text going to display on editable widget
    var value = getValue(dataGridRow, column.columnName);
    newCellValue = value;
    List<Enums>? enums = isEnumType(column.columnName);
    if (enums != null) {
      return Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: dropDownWidget(value, enums, submitCell)
      );
    }
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: isNumericType(column.columnName) ? Alignment.centerRight : Alignment.centerLeft,
      child: textFieldWidget(value?.toString() ?? '', column, submitCell)
    );
  }

  Widget textFieldWidget(String displayText, GridColumn column, CellSubmit submitCell) {
    return TextField(
      autofocus: true,
      controller: editingController..text = displayText,
      textAlign: isNumericType(column.columnName) ? TextAlign.right : TextAlign.left,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 16.0),
        suffixText: suffixText(column.columnName)
      ),
      keyboardType: isNumericType(column.columnName) ? TextInputType.number : TextInputType.text,
      inputFormatters: <TextInputFormatter>[
        if (isNumericType(column.columnName)) FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
      ],
      onChanged: (String value) {
        if (value.isNotEmpty) {
          if (isNumericType(column.columnName)) {
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
    );
  }

  Widget dropDownWidget(Enums value, List<Enums> enums, CellSubmit submitCell) {
    return DropdownButton<Enum>(
      value: value,
      autofocus: true,
      focusColor: Colors.transparent,
      underline: const SizedBox.shrink(),
      icon: const Icon(Icons.arrow_drop_down_sharp),
      isExpanded: true,
      style: DefaultTextStyle.of(context).style.copyWith(overflow: TextOverflow.ellipsis),
      onChanged: (Enum? value) {
        newCellValue = value;
        /// Call [CellSubmit] callback to fire the canSubmitCell and
        /// onCellSubmit to commit the new value in single place.
        submitCell();
      },
      items: enums.map<DropdownMenuItem<Enum>>((Enum e) {
        return DropdownMenuItem<Enum>(
          value: e,
          child: Text(AppLocalizations.of(context)!.text(e.toString().toLowerCase()))
        );
      }).toList()
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
            const Duration(seconds: 1), () => matches,
          );
        },
        onSelected: (String value) {
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
    return null;
  }

  @override
  int compare(DataGridRow? a, DataGridRow? b, SortColumnDetails sortColumn) {
    Object? getCellValue(List<DataGridCell>? cells, String columnName) {
      return cells?.firstWhereOrNull((DataGridCell element) => element.columnName == columnName)?.value;
    }

    Object? valueA = getCellValue(a?.getCells(), sortColumn.name);
    Object? valueB = getCellValue(b?.getCells(), sortColumn.name);

    if (valueA is LocalizedText) {
      valueA = valueA.toString();
    }
    if (valueB is LocalizedText) {
      valueB = valueB.toString();
    }

    return _compareTo(valueA, valueB, sortColumn.sortDirection);
  }

  int _compareTo(dynamic value1, dynamic value2, DataGridSortDirection sortDirection) {
    if (sortDirection == DataGridSortDirection.ascending) {
      if (value1 == null) {
        return -1;
      } else if (value2 == null) {
        return 1;
      }
      return value1.compareTo(value2) as int;
    } else {
      if (value1 == null) {
        return 1;
      } else if (value2 == null) {
        return -1;
      }
      return value2.compareTo(value1) as int;
    }
  }

  void updateDataSource() {
    notifyListeners();
  }
}