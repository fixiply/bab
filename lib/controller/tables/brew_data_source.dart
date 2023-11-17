import 'package:bab/models/equipment_model.dart';
import 'package:bab/models/recipe_model.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/tables/edit_data_source.dart';
import 'package:bab/models/brew_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/localized_text.dart';

// External package
import 'package:syncfusion_flutter_datagrid/datagrid.dart';


class BrewDataSource extends EditDataSource {
  List<BrewModel> _data = [];
  final void Function(BrewModel value, int dataRowIndex)? onChanged;
  /// Creates the employee data source class with required details.
  BrewDataSource(BuildContext context, {List<BrewModel>? data, bool? showCheckboxColumn, this.onChanged}) : super(context, showCheckboxColumn: showCheckboxColumn) {
    if (data != null) buildDataGridRows(data);
  }

  List<BrewModel> get data => _data;
  set data(List<BrewModel> data) => _data = data;

  List<DataGridRow> getDataRows({List<BrewModel>? data}) {
    List<BrewModel>? list = data ?? _data;
    return list.map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'uuid', value: e.uuid),
      DataGridCell<String>(columnName: 'reference', value: e.reference),
      DataGridCell<DateTime>(columnName: 'inserted_at', value: e.inserted_at),
      DataGridCell<RecipeModel>(columnName: 'receipt', value: e.receipt),
      DataGridCell<EquipmentModel>(columnName: 'tank', value: e.tank),
      DataGridCell<double>(columnName: 'volume', value: e.volume),
      DataGridCell<double>(columnName: 'efficiency', value: e.efficiency),
      DataGridCell<double>(columnName: 'abv', value: e.abv),
      DataGridCell<DateTime>(columnName: 'started', value: e.started_at),
    ])).toList();
  }

  void buildDataGridRows(List<BrewModel> data) {
    this.data = data;
    dataGridRows = getDataRows(data: data);
  }

  @override
  Future<void> handleLoadMoreRows() async {
    await Future.delayed(const Duration(seconds: 5));
    _addMoreRows(20);
    notifyListeners();
  }

  void _addMoreRows(int count) {
    List<BrewModel>? list = data.skip(dataGridRows.length).toList().take(count).toList();
    dataGridRows.addAll(getDataRows(data: list));
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
            if (e.columnName == 'efficiency' || e.columnName == 'abv') {
              value = AppLocalizations.of(context)!.percentFormat(e.value);
            } if (e.columnName == 'volume') {
              value = AppLocalizations.of(context)!.litterVolumeFormat(e.value);
            } else value = AppLocalizations.of(context)!.numberFormat(e.value);
            alignment = Alignment.centerRight;
          } else if (e.value is Enum) {
            alignment = Alignment.center;
            value = AppLocalizations.of(context)!.text(value.toString().toLowerCase());
          } else if (e.value is DateTime) {
            alignment = Alignment.centerRight;
            if (e.columnName == 'inserted_at') {
              value = AppLocalizations.of(context)!.dateFormat(e.value);
            } else value = AppLocalizations.of(context)!.datetimeFormat(e.value);
          } else if (e.value is RecipeModel) {
            value = AppLocalizations.of(context)!.localizedText(e.value.title);
          } else if (e.value is EquipmentModel) {
            value = e.value.name;
          }
          return Container(
            alignment: alignment,
            padding: const EdgeInsets.all(8.0),
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
    int columnIndex = showCheckboxColumn == true ? rowColumnIndex.columnIndex-1 : rowColumnIndex.columnIndex;
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
      case 'volume':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<double>(columnName: column.columnName, value: newCellValue);
        data[dataRowIndex].volume = newCellValue;
        break;
      case 'efficiency':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<double>(columnName: column.columnName, value: newCellValue);
        data[dataRowIndex].efficiency = newCellValue;
        break;
      case 'abv':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<double>(columnName: column.columnName, value: newCellValue);
        data[dataRowIndex].abv = newCellValue;
        break;
      case 'status':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<DateTime>(columnName: column.columnName, value: newCellValue);
        data[dataRowIndex].started_at = newCellValue;
        break;
    }
    onChanged?.call(data[dataRowIndex], dataRowIndex);
    updateDataSource();
  }

  @override
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
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.centerRight,
              child: Text(AppLocalizations.of(context)!.text('reference'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
          columnName: 'inserted_at',
          allowEditing: false,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.centerRight,
              child: Text(AppLocalizations.of(context)!.text('date'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
          columnName: 'receipt',
          allowEditing: false,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context)!.text('recipe'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
          columnName: 'tank',
          allowEditing: false,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context)!.text('tank'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
          columnName: 'volume',
          allowEditing: false,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context)!.text('volume'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
          columnName: 'efficiency',
          allowEditing: false,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context)!.text('efficiency'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
          columnName: 'abv',
          allowEditing: false,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context)!.text('alcohol'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
          columnName: 'started_at',
          allowEditing: true,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(AppLocalizations.of(context)!.text('started'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
    ];
  }
}

