import 'dart:convert';

import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/tables/edit_data_source.dart';
import 'package:bab/extensions/iterate_extensions.dart';
import 'package:bab/utils/app_localizations.dart';

// External package
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class Bluetooth<T> {
  String? service_uuid;
  String? read_charateristic_uuid;
  String? write_charateristic_uuid;
  String? target_temp_control;
  String? current_temp_control;

  Bluetooth({
    this.service_uuid,
    this.read_charateristic_uuid,
    this.write_charateristic_uuid,
    this.target_temp_control,
    this.current_temp_control,
  });

  void set(String key, String? value) {
    Map map = this.toMap();
    map[key] = value;
    this.fromMap(map);
  }

  void fromMap(Map<dynamic, dynamic> map) {
    this.service_uuid = map['service_uuid'];
    this.read_charateristic_uuid = map['read_charateristic_uuid'];
    this.write_charateristic_uuid = map['write_charateristic_uuid'];
    this.target_temp_control = map['target_temp_control'];
    this.current_temp_control = map['current_temp_control'];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'service_uuid': this.service_uuid,
      'read_charateristic_uuid': this.read_charateristic_uuid,
      'write_charateristic_uuid': this.write_charateristic_uuid,
      'target_temp_control': this.target_temp_control,
      'current_temp_control': this.current_temp_control,
    };
    return map;
  }

  Bluetooth copy() {
    return Bluetooth(
      service_uuid: this.service_uuid,
      read_charateristic_uuid: this.read_charateristic_uuid,
      write_charateristic_uuid: this.write_charateristic_uuid,
      target_temp_control: this.target_temp_control,
      current_temp_control: this.current_temp_control,
    );
  }

  // ignore: hash_and_equals
  @override
  bool operator ==(other) {
    return (other is Bluetooth && other.service_uuid == service_uuid || other is String && other == service_uuid);
  }

  int get hashCode => service_uuid.hashCode;

  @override
  String toString() {
    return 'Bluetooth: $service_uuid';
  }

  Future<BluetoothService?> getService(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    return services.firstWhereOrNull((item) => item.uuid == Guid(service_uuid!));
  }

  Future<BluetoothCharacteristic?> getReadCharateristic(BluetoothDevice device) async {
    BluetoothService? service = await getService(device);
    return service?.characteristics.firstWhereOrNull((item) => item.uuid == Guid(read_charateristic_uuid!));
  }

  Future<BluetoothCharacteristic?> getWriteCharateristic(BluetoothDevice device) async {
    BluetoothService? service = await getService(device);
    return service?.characteristics.firstWhereOrNull((item) => item.uuid == Guid(write_charateristic_uuid!));
  }

  double? getTargetTemperature(String value) {
    if (target_temp_control != null) {
      RegExp exp = RegExp(target_temp_control!);
      RegExpMatch? match = exp.firstMatch(value);
      if (match != null) {
        String? group = match.group(1);
        return group != null ? double.parse(group) : null;
      }
    }
    return null;
  }

  Future setTargetTemperature(BluetoothDevice device, double value) async {
    await write(device, 'X${value.toString()}');
  }

  double? getCurrentTemperature(String value) {
    if (current_temp_control != null) {
      RegExp exp = RegExp(current_temp_control!);
      RegExpMatch? match = exp.firstMatch(value);
      if (match != null) {
        String? group = match.group(1);
        return group != null ? double.parse(group) : null;
      }
    }
    return null;
  }

  Future setHeat(BluetoothDevice device, bool value) async {
    await write(device, value == true ? 'K1' : 'K0');
  }

  Future setPump(BluetoothDevice device, bool value) async {
    await write(device, value == true ? 'L1' : 'L0');
  }
  //
  Future write(BluetoothDevice device, String value) async {
    List<int> values = AsciiEncoder().convert(value);
    debugPrint('Write $value $values');
    BluetoothCharacteristic? wc = await getWriteCharateristic(device);
    if (wc != null) {
      debugPrint('Characteristic ${wc.toString()}');
      // await wc.descriptors.first.write(values);
    }
    BluetoothCharacteristic? rc = await getReadCharateristic(device);
    if (rc != null) {
      debugPrint('Characteristic ${rc.toString()}');
      await rc.descriptors.first.write(values);
      debugPrint('OK');
      // await rc.write(values);
    }
  }

  static List<GridColumn> columns({required BuildContext context}) {
    return <GridColumn>[
      GridColumn(
        allowEditing: false,
        columnName: 'name',
        label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: Text(AppLocalizations.of(context)!.text('name'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
        )
      ),
      GridColumn(
        allowEditing: true,
        columnName: 'value',
        label: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: Text(AppLocalizations.of(context)!.text('value'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
        )
      ),
    ];
  }

  static dynamic serialize(dynamic data) {
    if (data != null) {
      if (data is Bluetooth) {
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

  static dynamic deserialize(dynamic data) {
    if (data is Map<dynamic, dynamic>) {
      Bluetooth model = Bluetooth();
      model.fromMap(data);
      return model;
    } else {
      return data;
    }
  }
}

class BluetoothDataSource extends EditDataSource {
  Map data = {};
  final void Function(String key, String? value)? onChanged;
  /// Creates the employee data source class with required details.
  BluetoothDataSource(BuildContext context, {Map? data, bool? showQuantity, bool? showCheckboxColumn,  bool? showAction, this.onChanged}) : super(context, showQuantity: showQuantity, showAction: showAction, showCheckboxColumn: showCheckboxColumn) {
    if (data != null) buildDataGridRows(data);
  }

  void buildDataGridRows(Map data) {
    this.data = data;
    dataGridRows = data.entries.map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'name', value: e.key),
      DataGridCell<String>(columnName: 'value', value: e.value),
    ])).toList();
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
          Color? color;
          String? value = e.value?.toString();
          var alignment = Alignment.centerLeft;
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
      case 'value':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<String>(columnName: column.columnName, value: newCellValue);
        data[data.keys.elementAt(dataRowIndex)] = newCellValue;
        break;
    }
    onChanged?.call(data.keys.elementAt(dataRowIndex), newCellValue);
    updateDataSource();
  }

  @override
  void updateDataSource() {
    notifyListeners();
  }
}

