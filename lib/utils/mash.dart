import 'package:bab/helpers/device_helper.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/tables/edit_data_source.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/localized_text.dart';

// External package
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

enum Bearing with Enums { protein, amylolytique, mash_in, mash_out;
  List<Enum> get enums => [ protein, amylolytique, mash_in, mash_out];
}

enum Type with Enums { infusion, temperature, decoction;
  List<Enum> get enums => [ infusion, temperature, decoction ];
}

const String XML_ELEMENT_NAME = 'NAME';
const String XML_ELEMENT_STEP_TIME = 'STEP_TIME';
const String XML_ELEMENT_STEP_TEMP = 'STEP_TEMP';

class Mash<T> {
  dynamic name;
  Type? type;
  double? temperature;
  int? duration;

  Mash({
    this.name,
    this.type = Type.infusion,
    this.temperature = 65.0,
    this.duration
  });

  void fromMap(Map<String, dynamic> map) {
    this.name = LocalizedText.deserialize(map['name']);
    this.type = Type.values.elementAt(map['type']);
    if (map['temperature'] != null) this.temperature = map['temperature'].toDouble();
    this.duration = map['duration'];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'name': LocalizedText.serialize(this.name),
      'type': this.type!.index,
      'temperature': this.temperature,
      'duration': this.duration
    };
    return map;
  }

  Mash copy() {
    return Mash(
      name: this.name,
      type: this.type,
      temperature: this.temperature,
      duration: this.duration,
    );
  }

  @override
  String toString() {
    return 'Mash: $name';
  }

  static dynamic serialize(dynamic data) {
    if (data != null) {
      if (data is Mash) {
        return data.toMap();
      }
      if (data is List) {
        List<dynamic> values = [];
        for(final value in data) {
          values.add(serialize(value));
        }
        return values;
      }
    }
    return null;
  }

  static List<Mash> deserialize(dynamic data) {
    List<Mash> values = [];
    if (data != null) {
      if (data is List) {
        for(final value in data) {
          values.addAll(deserialize(value));
        }
      } else {
        Mash model = Mash();
        model.fromMap(data);
        values.add(model);
      }
    }
    return values;
  }

  static List<GridColumn> columns({required BuildContext context, bool showAction = false}) {
    return <GridColumn>[
      GridColumn(
        columnName: 'name',
        label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: Text(AppLocalizations.of(context)!.text('name'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
        )
      ),
      GridColumn(
        columnName: 'type',
        label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: Text(AppLocalizations.of(context)!.text('type'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
        )
      ),
      GridColumn(
        width: 90,
        columnName: 'temperature',
        label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerRight,
            child: Text(AppLocalizations.of(context)!.text('temperature'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
        )
      ),
      GridColumn(
        width: 90,
        columnName: 'duration',
        allowEditing: DeviceHelper.isDesktop,
        label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerRight,
            child: Text(AppLocalizations.of(context)!.text('duration'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
        )
      ),
      if (DeviceHelper.isDesktop && showAction == true) GridColumn(
          width: 50,
          columnName: 'actions',
          allowSorting: false,
          allowEditing: false,
          label: Container()
      ),
    ];
  }
}

class MashDataSource extends EditDataSource {
  List<Mash> data = [];
  final void Function(Mash value, int dataRowIndex)? onChanged;
  final void Function(int rowIndex)? onRemove;
  /// Creates the employee data source class with required details.
  MashDataSource(BuildContext context, {List<Mash>? data, bool? showQuantity, bool? showCheckboxColumn, bool? showAction, this.onChanged, this.onRemove}) : super(context, showQuantity: showQuantity, showAction: showAction, showCheckboxColumn: showCheckboxColumn) {
    if (data != null) buildDataGridRows(data);
  }

  void buildDataGridRows(List<Mash> data) {
    this.data = data;
    int index = 0;
    dataGridRows = data.map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<dynamic>(columnName: 'name', value: e.name),
      DataGridCell<Type>(columnName: 'type', value: e.type),
      DataGridCell<double>(columnName: 'temperature', value: e.temperature),
      DataGridCell<int>(columnName: 'duration', value: e.duration),
      if (DeviceHelper.isDesktop && showAction == true) DataGridCell<int>(columnName: 'actions', value: index++),
    ])).toList();
  }

  @override
  Widget? buildEditWidget(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex, GridColumn column, CellSubmit submitCell) {
    if (column.columnName == 'name') {
      var value = getValue(dataGridRow, column.columnName);
      newCellValue = value;
      return TextField(
        controller: editingController..text = value ?? '',
        decoration: InputDecoration(
          suffixIcon: PopupMenuButton<String>(
            icon: const Icon(Icons.arrow_drop_down),
            onSelected: (String value) {
              newCellValue = value;
              submitCell();
            },
            itemBuilder: (BuildContext context) {
              return ['Mash In', 'Mash Out'].map<PopupMenuItem<String>>((String value) {
                return new PopupMenuItem(
                    child: new Text(value), value: value);
              }).toList();
            },
          ),
        ),
        onChanged: (value) {
          newCellValue = value;
        },
        onSubmitted: (String value) {
          submitCell();
        },
      );
    }
    return super.buildEditWidget(dataGridRow, rowColumnIndex, column, submitCell);
  }

  @override
  bool isNumericType(String columnName) {
    return columnName == 'temperature' || columnName == 'duration';
  }

  @override
  List<Enums>? isEnumType(String columnName) {
    if (columnName == 'type') {
      return Type.values;
    }
    return null;
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((e) {
        Color? color;
        String? value = e.value?.toString();
        var alignment = Alignment.centerLeft;
        if (e.value is LocalizedText) {
          value = e.value?.get(AppLocalizations.of(context)!.locale);
          alignment = Alignment.centerLeft;
        } else if (e.value is num) {
          if (e.columnName == 'temperature') {
            value = AppLocalizations.of(context)!.tempFormat(e.value);
          } else if (e.columnName == 'duration') {
            value = AppLocalizations.of(context)!.durationFormat(e.value);
          } else value = NumberFormat("#0.#", AppLocalizations.of(context)!.locale.toString()).format(e.value);
          alignment = Alignment.centerRight;
        } else if (e.value is Enum) {
          alignment = Alignment.center;
          value = AppLocalizations.of(context)!.text(value.toString().toLowerCase());
        }
        if (e.columnName == 'actions') {
          return PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              tooltip: AppLocalizations.of(context)!.text('options'),
              onSelected: (value) async {
                if (value == 'remove') {
                  onRemove?.call(e.value);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem(
                  value: 'remove',
                  child: Text(AppLocalizations.of(context)!.text('remove')),
                ),
              ]
          );
        }
        return Container(
          color: color,
          alignment: alignment,
          padding: const EdgeInsets.all(8.0),
          child: Text(value ?? ''),
        );
      }).toList()
    );
  }

  @override
  Future<void> onCellSubmit(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex, GridColumn column) async {
    final dynamic oldValue = dataGridRow.getCells().firstWhere((DataGridCell dataGridCell) =>
    dataGridCell.columnName == column.columnName).value ?? '';
    final int dataRowIndex = dataGridRows.indexOf(dataGridRow);
    if (newCellValue == null || oldValue == newCellValue) {
      return;
    }
    int columnIndex = showCheckboxColumn == true ? rowColumnIndex.columnIndex-1 : rowColumnIndex.columnIndex;
    switch(column.columnName) {
      case 'name':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<String>(columnName: column.columnName, value: newCellValue);
        if (data[dataRowIndex].name is LocalizedText) {
          data[dataRowIndex].name.add(AppLocalizations.of(context)!.locale, newCellValue);
        }
        else data[dataRowIndex].name = newCellValue;
        break;
      case 'type':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<Type>(columnName: column.columnName, value: newCellValue);
        data[dataRowIndex].type = newCellValue as Type;
        break;
      case 'temperature':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<double>(columnName: column.columnName, value: newCellValue);
        data[dataRowIndex].temperature = newCellValue as double;
        break;
      case 'duration':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<int>(columnName: column.columnName, value: newCellValue);
        data[dataRowIndex].duration = newCellValue as int;
        break;
    }
    onChanged?.call(data[dataRowIndex], rowColumnIndex.rowIndex);
    updateDataSource();
  }

  @override
  void updateDataSource() {
    notifyListeners();
  }
}
