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

class Fermentation<T> {
  dynamic name;
  int? duration;
  double? temperature;

  Fermentation({
    this.name,
    this.duration = 10,
    this.temperature = 18.0,
  });

  void fromMap(Map<String, dynamic> map) {
    this.name = LocalizedText.deserialize(map['name']);
    this.duration = map['duration'];
    if (map['temperature'] != null) this.temperature = map['temperature'].toDouble();
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'name': LocalizedText.serialize(this.name),
      'duration': this.duration,
      'temperature': this.temperature,
    };
    return map;
  }

  Fermentation copy() {
    return Fermentation(
      name: this.name,
      duration: this.duration,
      temperature: this.temperature,
    );
  }

  @override
  String toString() {
    return 'Fermentation: $name';
  }

  static dynamic serialize(dynamic data) {
    if (data != null) {
      if (data is Fermentation) {
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

  static List<Fermentation> deserialize(dynamic data) {
    List<Fermentation> values = [];
    if (data != null) {
      if (data is List) {
        for(final value in data) {
          values.addAll(deserialize(value));
        }
      } else {
        Fermentation model = Fermentation();
        model.fromMap(data);
        values.add(model);
      }
    }
    return values;
  }

  static List<GridColumn> columns({required BuildContext context, bool allowEditing = false}) {
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
        width: 90,
        columnName: 'duration',
        allowEditing: DeviceHelper.isDesktop,
        label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerRight,
            child: Text(AppLocalizations.of(context)!.text('duration'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
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
      if (DeviceHelper.isDesktop && allowEditing == true) GridColumn(
          width: 50,
          columnName: 'actions',
          allowSorting: false,
          allowEditing: false,
          label: Container()
      ),
    ];
  }
}

class FermentationDataSource extends EditDataSource {
  List<Fermentation> data = [];
  final void Function(Fermentation value, int dataRowIndex)? onChanged;
  final void Function(int rowIndex)? onRemove;
  /// Creates the employee data source class with required details.
  FermentationDataSource(BuildContext context, {List<Fermentation>? data, bool? showQuantity, bool? showCheckboxColumn,  bool? allowEditing, this.onChanged, this.onRemove}) : super(context, showQuantity: showQuantity, allowEditing: allowEditing, showCheckboxColumn: showCheckboxColumn) {
    if (data != null) buildDataGridRows(data);
  }

  void buildDataGridRows(List<Fermentation> data) {
    this.data = data;
    int index = 0;
    dataGridRows = data.map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<dynamic>(columnName: 'name', value: e.name),
      DataGridCell<int>(columnName: 'duration', value: e.duration),
      DataGridCell<double>(columnName: 'temperature', value: e.temperature),
      if (DeviceHelper.isDesktop && allowEditing == true) DataGridCell<int>(columnName: 'actions', value: index++),
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
              return [
                AppLocalizations.of(context)!.text('primary'),
                AppLocalizations.of(context)!.text('secondary'),
                AppLocalizations.of(context)!.text('tertiary'),
                'Cold Crash'
              ].map<PopupMenuItem<String>>((String value) {
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
            value = AppLocalizations.of(context)!.durationFormat(e.value * 1440);
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
      case 'duration':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<int>(columnName: column.columnName, value: newCellValue);
        data[dataRowIndex].duration = newCellValue as int;
        break;
      case 'temperature':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<double>(columnName: column.columnName, value: newCellValue);
        data[dataRowIndex].temperature = newCellValue as double;
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
