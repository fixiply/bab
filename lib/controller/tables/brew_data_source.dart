import 'package:bb/models/equipment_model.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/tables/edit_data_source.dart';
import 'package:bb/models/brew_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/utils/localized_text.dart';

// External package
import 'package:syncfusion_flutter_datagrid/datagrid.dart';


class BrewDataSource extends EditDataSource {
  List<BrewModel> data = [];
  final void Function(BrewModel value, int dataRowIndex)? onChanged;
  /// Creates the employee data source class with required details.
  BrewDataSource(BuildContext context, {List<BrewModel>? data, bool? showCheckboxColumn, this.onChanged}) : super(context, showCheckboxColumn: showCheckboxColumn!) {
    if (data != null) buildDataGridRows(data);
  }

  void buildDataGridRows(List<BrewModel> data) async {
    this.data = data;
    dataGridRows = data.map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'uuid', value: e.uuid),
      DataGridCell<String>(columnName: 'reference', value: e.reference),
      DataGridCell<DateTime>(columnName: 'inserted_at', value: e.inserted_at),
      DataGridCell<ReceiptModel>(columnName: 'receipt', value: e.receipt),
      DataGridCell<EquipmentModel>(columnName: 'tank', value: e.tank),
      DataGridCell<EquipmentModel>(columnName: 'fermenter', value: e.fermenter),
      DataGridCell<Status>(columnName: 'status', value: e.status),
    ])).toList();
  }

  @override
  bool isNumericType(String columnName) {
    return BrewModel().isNumericType(columnName);
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
          String? value = e.value?.toString();
          var alignment = Alignment.centerLeft;
          if (e.value is LocalizedText) {
            value = e.value?.get(AppLocalizations.of(context)!.locale);
            alignment = Alignment.centerLeft;
          } else if (e.value is num) {
            AppLocalizations.of(context)!.numberFormat(e.value);
            alignment = Alignment.centerRight;
          } else if (e.value is Enum) {
            alignment = Alignment.center;
            value = AppLocalizations.of(context)!.text(value.toString().toLowerCase());
          } else if (e.value is DateTime) {
            alignment = Alignment.centerRight;
            if (e.columnName == 'inserted_at') {
              value = AppLocalizations.of(context)!.dateFormat(e.value);
            } else value = AppLocalizations.of(context)!.datetimeFormat(e.value);
          } else if (e.value is ReceiptModel) {
            value = AppLocalizations.of(context)!.localizedText(e.value.title);
          } else if (e.value is EquipmentModel) {
            value = e.value.name;
          }
          return Container(
            alignment: alignment,
            padding: EdgeInsets.all(8.0),
            child: Text(value ?? ''),
          );
        }).toList()
    );
  }

  @override
  Future<void> onCellSubmit(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex, GridColumn column) async {
    final dynamic oldValue = dataGridRow.getCells()
        .firstWhere((DataGridCell dataGridCell) =>
    dataGridCell.columnName == column.columnName).value ?? '';
    final int dataRowIndex = dataGridRows.indexOf(dataGridRow);
    if (dataRowIndex == -1 || oldValue == newCellValue) {
      return;
    }
    int columnIndex = showCheckboxColumn ? rowColumnIndex.columnIndex-1 : rowColumnIndex.columnIndex;
    switch(column.columnName) {
      case 'reference':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<String>(columnName: column.columnName, value: newCellValue);
        data[dataRowIndex].reference = newCellValue;
        break;
      case 'receipt':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<String>(columnName: column.columnName, value: newCellValue);
        data[dataRowIndex].receipt = newCellValue;
        break;
      case 'tank':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<String>(columnName: column.columnName, value: newCellValue);
        data[dataRowIndex].tank = newCellValue;
        break;
      case 'fermenter':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<String>(columnName: column.columnName, value: newCellValue);
        data[dataRowIndex].fermenter = newCellValue;
        break;
      case 'status':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<Status>(columnName: column.columnName, value: newCellValue);
        data[dataRowIndex].status = newCellValue;
        break;
    }
    onChanged?.call(data[dataRowIndex], dataRowIndex);
    updateDataSource();
  }

  void updateDataSource() {
    notifyListeners();
  }

  static List<GridColumn> columns({required BuildContext context, bool showQuantity = false}) {
    return <GridColumn>[
      GridColumn(
          columnName: 'uuid',
          visible: false,
          label: Container()
      ),
      GridColumn(
          width: 100,
          columnName: 'reference',
          allowEditing: false,
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.centerRight,
              child: Text(AppLocalizations.of(context)!.text('reference'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
          columnName: 'inserted_at',
          allowEditing: false,
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.centerRight,
              child: Text(AppLocalizations.of(context)!.text('date'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
          columnName: 'receipt',
          allowEditing: false,
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context)!.text('receipt'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
          columnName: 'tank',
          allowEditing: false,
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context)!.text('tank'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
          columnName: 'fermenter',
          allowEditing: false,
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(AppLocalizations.of(context)!.text('fermenter'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
          columnName: 'status',
          allowEditing: true,
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(AppLocalizations.of(context)!.text('status'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
    ];
  }
}

