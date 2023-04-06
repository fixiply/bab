import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/tables/edit_data_source.dart';
import 'package:bb/helpers/formula_helper.dart';
import 'package:bb/models/model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/color_units.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/localized_text.dart';
import 'package:bb/utils/quantity.dart';
import 'package:intl/intl.dart';

// External package
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

enum Type with Enums { grain, sugar, extract,  dry_extract, adjunct, fruit, juice, honey;
  List<Enum> get enums => [ grain, sugar, extract,  dry_extract, adjunct, fruit, juice, honey ];
}

enum Method with Enums { mashed,  steeped;
  List<Enum> get enums => [ mashed,  steeped ];
}

extension Ex on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

class FermentableModel<T> extends Model {
  Status? status;
  dynamic? name;
  Type? type;
  String? origin;
  double? amount;
  Method? method;
  double? efficiency;
  int? ebc;
  dynamic? notes;

  FermentableModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    bool? isEdited,
    bool? isSelected,
    this.status = Status.publied,
    this.name,
    this.type = Type.grain,
    this.origin,
    this.amount,
    this.method = Method.mashed,
    this.efficiency,
    this.ebc,
    this.notes,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator, isEdited: isEdited, isSelected: isSelected);

  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    this.name = LocalizedText.deserialize(map['name']);
    this.type = Type.values.elementAt(map['type']);
    this.origin = map['origin'];
    // if (map['amount'] != null) this.amount = map['amount'].toDouble();
    // this.method = Method.values.elementAt(map['method']);
    if (map['efficiency'] != null) this.efficiency = map['efficiency'].toDouble();
    this.ebc = map['ebc'];
    this.notes = LocalizedText.deserialize(map['notes']);
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'name': LocalizedText.serialize(this.name),
      'type': this.type!.index,
      'origin': this.origin,
      // 'amount': this.amount,
      // 'method': this.method!.index,
      'efficiency': this.efficiency,
      'ebc': this.ebc,
      'notes': LocalizedText.serialize(this.notes),
    });
    return map;
  }

  FermentableModel copy() {
    return FermentableModel(
      uuid: this.uuid,
      inserted_at: this.inserted_at,
      updated_at: this.updated_at,
      creator: this.creator,
      status: this.status,
      name: this.name,
      type: this.type,
      origin: this.origin,
      amount: this.amount,
      method: this.method,
      efficiency: this.efficiency,
      ebc: this.ebc,
      notes: this.notes,
    );
  }

  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is FermentableModel && other.uuid == uuid);
  }

  @override
  String toString() {
    return 'FermentableModel: $name, UUID: $uuid';
  }

  /// Returns the dry extract, based on the given conditions.
  ///
  /// The `efficiency` argument is relative to the theoretical efficiency of the equipment.
  double extract(double? efficiency) {
    return FormulaHelper.extract(this.amount, this.efficiency, efficiency);
  }

  static dynamic serialize(dynamic data) {
    if (data != null) {
      if (data is FermentableModel) {
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

  static List<FermentableModel> merge(List<Quantity>? quantities, List<FermentableModel> fermentables) {
    List<FermentableModel> list = [];
    if (quantities != null && fermentables != null) {
      for (Quantity quantity in quantities) {
        for (FermentableModel fermentable in fermentables) {
          if (quantity.uuid == fermentable.uuid) {
            FermentableModel model = fermentable.copy();
            model.amount = quantity.amount;
            model.method = quantity.use != null
                ? Method.values.elementAt(quantity.use!)
                : Method.mashed;
            list.add(model);
            break;
          }
        }
      }
    }
    return list;
  }

  static List<FermentableModel> deserialize(dynamic data) {
    List<FermentableModel> values = [];
    if (data != null) {
      if (data is List) {
        for(final value in data) {
          values.addAll(deserialize(value));
        }
      } else {
        FermentableModel model = new FermentableModel();
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
      if (showQuantity == true) GridColumn(
          width: 90,
          columnName: 'amount',
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.centerRight,
              child: Text(AppLocalizations.of(context)!.text('amount'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
          columnName: 'name',
          allowEditing: showQuantity == false,
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context)!.text('name'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
          width: 50,
          columnName: 'origin',
          allowEditing: showQuantity == false,
          allowSorting: false,
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context)!.text('origin'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
          columnName: 'type',
          allowEditing: showQuantity == false,
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(AppLocalizations.of(context)!.text('type'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      if (showQuantity == true) GridColumn(
          columnName: 'method',
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(AppLocalizations.of(context)!.text('method'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
          width: 90,
          columnName: 'efficiency',
          allowEditing: showQuantity == false,
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.centerRight,
              child: Text(AppLocalizations.of(context)!.text('yield'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
          width: 90,
          columnName: 'color',
          allowEditing: showQuantity == false,
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(AppLocalizations.of(context)!.colorUnit, style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
    ];
  }
}

class FermentableDataSource extends EditDataSource {
  List<FermentableModel> _data = [];
  final void Function(FermentableModel value, int dataRowIndex)? onChanged;
  /// Creates the employee data source class with required details.
  FermentableDataSource(BuildContext context, {List<FermentableModel>? data, bool? showQuantity, bool? showCheckboxColumn, this.onChanged}) : super(context, showQuantity: showQuantity!, showCheckboxColumn: showCheckboxColumn!) {
    if (data != null) buildDataGridRows(data);
  }

  List<FermentableModel> get data => _data;
  set data(List<FermentableModel> data) => _data = data;

  List<DataGridRow> getDataRows({List<FermentableModel>? data}) {
    List<FermentableModel>? list = data ?? _data;
    return list.map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'uuid', value: e.uuid),
      if (showQuantity == true) DataGridCell<double>(columnName: 'amount', value: e.amount),
      DataGridCell<dynamic>(columnName: 'name', value: e.name),
      DataGridCell<dynamic>(columnName: 'origin', value: e.origin),
      DataGridCell<Type>(columnName: 'type', value: e.type),
      if (showQuantity == true) DataGridCell<Method>(columnName: 'method', value: e.method),
      DataGridCell<double>(columnName: 'efficiency', value: e.efficiency),
      DataGridCell<int>(columnName: 'color', value: e.ebc),
    ])).toList();
  }

  void buildDataGridRows(List<FermentableModel> data) {
    this.data = data;
    dataGridRows = getDataRows(data: data);
  }

  @override
  Future<void> handleLoadMoreRows() async {
    await Future.delayed(Duration(seconds: 5));
    _addMoreRows(20);
    notifyListeners();
  }

  void _addMoreRows(int count) {
    List<FermentableModel>? list = data.skip(dataGridRows.length).toList().take(count).toList();
    dataGridRows.addAll(getDataRows(data: list));
  }

  dynamic? getValue(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex, GridColumn column) {
    var value = super.getValue(dataGridRow, rowColumnIndex, column);
    if (value != null && column.columnName == 'amount') {
      double? weight = AppLocalizations.of(context)!.weight(value * 1000, weight: Weight.kilo);
      return weight!.toPrecision(2);
    }
    return value;
  }

  @override
  String? suffixText(GridColumn column) {
    if (column.columnName == 'amount') {
      return AppLocalizations.of(context)!.weightSuffix(weight: Weight.kilo);
    }
    return null;
  }

  @override
  bool isNumericType(GridColumn column) {
    return column.columnName == 'amount' || column.columnName == 'efficiency';
  }

  @override
  Enums? isEnums(GridColumn column) {
    if (column.columnName == 'method') {
      return Method.mashed;
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
          if (e.columnName == 'amount') {
            value = AppLocalizations.of(context)!.weightFormat(e.value * 1000);
          } else if (e.columnName == 'efficiency') {
            value = AppLocalizations.of(context)!.percentFormat(e.value);
          } else value = NumberFormat("#0.#", AppLocalizations.of(context)!.locale.toString()).format(e.value);
          alignment = Alignment.centerRight;
        } else if (e.value is Enum) {
          alignment = Alignment.center;
          value = AppLocalizations.of(context)!.text(value.toString().toLowerCase());
        } else {
          if (e.columnName == 'amount') {
            return Container(
              alignment: Alignment.center,
              margin: EdgeInsets.all(4),
              child: Icon(Icons.warning_amber_outlined, size: 18, color: Colors.redAccent.withOpacity(0.3))
            );
          }
        }
        if (e.columnName == 'color') {
          return Container(
            margin: EdgeInsets.all(4),
            color: ColorUnits.color(e.value),
            child: Center(child: Text(value ?? '', style: TextStyle(color: Colors.white, fontSize: 14)))
          );
        }
        if (e.columnName == 'origin') {
          if (value != null) {
            return Container(
              margin: EdgeInsets.all(4),
              child: Center(child: Text(LocalizedText.emoji(value),
                  style: TextStyle(fontSize: 16, fontFamily: 'Emoji')))
            );
          }
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
  void onCellSubmit(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex, GridColumn column) {
    final dynamic oldValue = dataGridRow.getCells().firstWhere((DataGridCell dataGridCell) =>
      dataGridCell.columnName == column.columnName).value ?? '';
    final int dataRowIndex = dataGridRows.indexOf(dataGridRow);
    if (dataRowIndex == -1 || oldValue == newCellValue) {
      return;
    }
    int columnIndex = showCheckboxColumn ? rowColumnIndex.columnIndex-1 : rowColumnIndex.columnIndex;
    switch(column.columnName) {
      case 'amount':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<double>(columnName: column.columnName, value: newCellValue);
        _data[dataRowIndex].amount = AppLocalizations.of(context)!.gram(newCellValue * 1000, weight: Weight.kilo);
        break;
      case 'name':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<String>(columnName: column.columnName, value: newCellValue);
        if (_data[dataRowIndex].name is LocalizedText) {
          _data[dataRowIndex].name.add(AppLocalizations.of(context)!.locale, newCellValue);
        }
        else _data[dataRowIndex].name = newCellValue;
        break;
      case 'origin':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<String>(columnName: column.columnName, value: newCellValue);
        _data[dataRowIndex].name = newCellValue;
        break;
      case 'type':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<Type>(columnName: column.columnName, value: newCellValue);
        _data[dataRowIndex].type = newCellValue;
        break;
      case 'method':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<Method>(columnName: column.columnName, value: newCellValue);
        _data[dataRowIndex].method = newCellValue;
        break;
      case 'efficiency':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<double>(columnName: column.columnName, value: newCellValue);
        _data[dataRowIndex].efficiency = newCellValue;
        break;
      case 'color':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<double>(columnName: column.columnName, value: newCellValue);
        _data[dataRowIndex].ebc = newCellValue;
        break;
    }
    onChanged?.call(_data[dataRowIndex], dataRowIndex);
    updateDataSource();
  }

  void updateDataSource() {
    notifyListeners();
  }
}
