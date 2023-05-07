import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/tables/edit_data_source.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/localized_text.dart';

// External package
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

enum Bearing with Enums { protein, amylolytique, mash_in, mash_out;
  List<Enum> get enums => [ protein, amylolytique, mash_in, mash_out];
}

enum Type with Enums { infusion, temperature, decoction;
  List<Enum> get enums => [ infusion, temperature, decoction ];
}

class Mash<T> {
  String? uuid;
  dynamic? name;
  Type? type;
  double? temperature;
  int? duration;

  Mash({
    this.uuid,
    this.name,
    this.type = Type.infusion,
    this.temperature = 65.0,
    this.duration,
  });

  void fromMap(Map<String, dynamic> map) {
    this.uuid = map['uuid'];
    this.name = LocalizedText.deserialize(map['name']);
    this.type = Type.values.elementAt(map['type']);
    if (map['temperature'] != null) this.temperature = map['temperature'].toDouble();
    this.duration = map['duration'];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'uuid': this.uuid,
      'name': LocalizedText.serialize(this.name),
      'type': this.type!.index,
      'temperature': this.temperature,
      'duration': this.duration
    };
    return map;
  }

  Mash copy() {
    return Mash(
      uuid: this.uuid,
      name: this.name,
      type: this.type,
      temperature: this.temperature,
      duration: this.duration,
    );
  }

  @override
  String toString() {
    return 'Mash: $uuid';
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
        Mash model = new Mash();
        model.fromMap(data);
        values.add(model);
      }
    }
    return values;
  }

  static List<GridColumn> columns({required BuildContext context, bool showQuantity = false}) {
    return <GridColumn>[
      GridColumn(
          columnName: 'uuid',
          visible: false,
          label: Container()
      ),
      GridColumn(
          columnName: 'name',
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context)!.text('name'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
          columnName: 'type',
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(AppLocalizations.of(context)!.text('type'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
        width: 90,
        columnName: 'temperature',
        label: Container(
            padding: EdgeInsets.all(8.0),
            alignment: Alignment.centerRight,
            child: Text(AppLocalizations.of(context)!.text('temperature'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
        )
      ),
      GridColumn(
        width: 90,
        columnName: 'duration',
        label: Container(
            padding: EdgeInsets.all(8.0),
            alignment: Alignment.centerRight,
            child: Text(AppLocalizations.of(context)!.text('duration'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
        )
      )
    ];
  }
}

class MashDataSource extends EditDataSource {
  List<Mash> data = [];
  final void Function(Mash value)? onChanged;
  /// Creates the employee data source class with required details.
  MashDataSource(BuildContext context, {List<Mash>? data, bool? showCheckboxColumn, this.onChanged}) : super(context, showQuantity: false, showCheckboxColumn: showCheckboxColumn!) {
    if (data != null) buildDataGridRows(data);
  }

  void buildDataGridRows(List<Mash> data) {
    this.data = data;
    dataGridRows = data.map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'uuid', value: e.uuid),
      DataGridCell<dynamic>(columnName: 'name', value: e.name),
      DataGridCell<Type>(columnName: 'type', value: e.type),
      DataGridCell<double>(columnName: 'temperature', value: e.temperature),
      DataGridCell<int>(columnName: 'duration', value: e.duration)
    ])).toList();
  }

  Widget? buildEditWidget(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex, GridColumn column, CellSubmit submitCell) {
    if (column.columnName == 'name') {
      return super.typeHeadWidget(Bearing.protein, submitCell);
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

          return Container(
            color: color,
            alignment: alignment,
            padding: EdgeInsets.all(8.0),
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
    int columnIndex = showCheckboxColumn ? rowColumnIndex.columnIndex-1 : rowColumnIndex.columnIndex;
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
    onChanged?.call(data[dataRowIndex]);
    updateDataSource();
  }

  void updateDataSource() {
    notifyListeners();
  }
}
