import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/tables/edit_data_source.dart';
import 'package:bb/models/model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/localized_text.dart';
import 'package:bb/utils/quantity.dart';
import 'package:intl/intl.dart';

// External package
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

enum Misc with Enums { spice, fining, water_agent, herb, flavor, other;
  List<Enum> get enums => [ spice, fining, water_agent, herb, flavor, other ];
}

enum Use with Enums { boil, mash, primary, secondary, bottling, sparge;
  List<Enum> get enums => [ boil, mash, primary, secondary, bottling, sparge ];
}

extension Ex on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

class MiscellaneousModel<T> extends Model {
  Status? status;
  dynamic? name;
  Misc? type;
  Use? use;
  int? time;
  double? amount;
  dynamic? notes;

  MiscellaneousModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    bool? isEdited,
    bool? isSelected,
    this.status = Status.publied,
    this.name,
    this.type = Misc.flavor,
    this.use = Use.mash,
    this.time,
    this.amount,
    this.notes,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator, isEdited: isEdited, isSelected: isSelected);

  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    this.name = LocalizedText.deserialize(map['name']);
    this.type = Misc.values.elementAt(map['type']);
    // if (map['use'] != null) this.use = MiscUse.values.elementAt(map['use']);
    // this.time = map['time'];
    this.notes = LocalizedText.deserialize(map['notes']);
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'name': LocalizedText.serialize(this.name),
      'type': this.type!.index,
      // 'use': this.use!.index,
      // 'time': this.time,
      // 'amount': this.amount,
      'notes': LocalizedText.serialize(this.notes),
    });
    return map;
  }

  MiscellaneousModel copy() {
    return MiscellaneousModel(
      uuid: this.uuid,
      inserted_at: this.inserted_at,
      updated_at: this.updated_at,
      creator: this.creator,
      status: this.status,
      name: this.name,
      type: this.type,
      use: this.use,
      time: this.time,
      amount: this.amount,
      notes: this.notes,
    );
  }

  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is MiscellaneousModel && other.uuid == uuid);
  }

  @override
  String toString() {
    return 'MiscellaneousModel: $name, UUID: $uuid';
  }

  static List<MiscellaneousModel> merge(List<Quantity>? quantities, List<MiscellaneousModel> miscellaneous) {
    List<MiscellaneousModel> list = [];
    if (quantities != null && miscellaneous != null) {
      for (Quantity quantity in quantities) {
        for (MiscellaneousModel misc in miscellaneous) {
          if (quantity.uuid == misc.uuid) {
            MiscellaneousModel model = misc.copy();
            model.amount = quantity.amount;
            model.time = quantity.duration;
            model.use = quantity.use != null
                ? Use.values.elementAt(quantity.use!)
                : Use.boil;
            list.add(model);
            break;
          }
        }
      }
    }
    return list;
  }

  static dynamic serialize(dynamic data) {
    if (data != null) {
      if (data is MiscellaneousModel) {
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

  static List<MiscellaneousModel> deserialize(dynamic data) {
    List<MiscellaneousModel> values = [];
    if (data != null) {
      if (data is List) {
        for(final value in data) {
          values.addAll(deserialize(value));
        }
      } else {
        MiscellaneousModel model = new MiscellaneousModel();
        model.fromMap(data);
        values.add(model);
      }
    }
    return values;
  }
  static List<GridColumn> columns({required BuildContext context, bool showQuantity = false}) {
    return [
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
          columnName: 'type',
          allowEditing: showQuantity == false,
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(AppLocalizations.of(context)!.text('type'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      if (showQuantity == true) GridColumn(
          columnName: 'use',
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(AppLocalizations.of(context)!.text('use'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      if (showQuantity == true) GridColumn(
          width: 90,
          columnName: 'time',
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.centerRight,
              child: Text(AppLocalizations.of(context)!.text('time'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
    ];
  }
}

class MiscellaneousDataSource extends EditDataSource {
  List<MiscellaneousModel> data = [];
  final void Function(MiscellaneousModel value, int dataRowIndex)? onChanged;
  /// Creates the employee data source class with required details.
  MiscellaneousDataSource(BuildContext context, {List<MiscellaneousModel>? data, bool? showQuantity, bool? showCheckboxColumn, this.onChanged}) : super(context, showQuantity: showQuantity!, showCheckboxColumn: showCheckboxColumn!) {
    if (data != null) buildDataGridRows(data);
  }

  void buildDataGridRows(List<MiscellaneousModel> data) {
    this.data = data;
    dataGridRows = data.map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'uuid', value: e.uuid),
      if (showQuantity == true) DataGridCell<double>(columnName: 'amount', value: e.amount),
      DataGridCell<dynamic>(columnName: 'name', value: e.name),
      DataGridCell<Misc>(columnName: 'type', value: e.type),
      if (showQuantity == true) DataGridCell<Use>(columnName: 'use', value: e.use),
      if (showQuantity == true)  DataGridCell<int>(columnName: 'time', value: e.time),
    ])).toList();
  }

  dynamic? getValue(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex, GridColumn column) {
    var value = super.getValue(dataGridRow, rowColumnIndex, column);
    if (value != null && column.columnName == 'amount') {
      double? weight = AppLocalizations.of(context)!.weight(value);
      return weight!.toPrecision(2);
    }
    return value;
  }

  @override
  String? suffixText(GridColumn column) {
    if (column.columnName == 'amount') {
      return AppLocalizations.of(context)!.weightSuffix();
    }
    return null;
  }

  @override
  bool isNumericType(GridColumn column) {
    return column.columnName == 'amount' || column.columnName == 'time';
  }

  @override
  Enums? isEnums(GridColumn column) {
    if (column.columnName == 'use') {
      return Use.mash;
    }
    return null;
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
            if (e.columnName == 'amount') {
              value = AppLocalizations.of(context)!.weightFormat(e.value);
            } if (e.columnName == 'duration') {
              value = AppLocalizations.of(context)!.durationFormat(e.value);
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
          return Container(
            alignment: alignment,
            padding: EdgeInsets.all(8.0),
            child: Text(value ?? ''),
          );
        }).toList()
    );
  }

  @override
  void onCellSubmit(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex, GridColumn column) {
    final dynamic oldValue = dataGridRow.getCells()
        .firstWhere((DataGridCell dataGridCell) =>
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
        data[dataRowIndex].amount = AppLocalizations.of(context)!.gram(newCellValue);
        break;
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
            DataGridCell<Misc>(columnName: column.columnName, value: newCellValue);
        data[dataRowIndex].type = newCellValue;
        break;
      case 'use':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<Use>(columnName: column.columnName, value: newCellValue);
        data[dataRowIndex].use = newCellValue;
        break;
      case 'time':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<int>(columnName: column.columnName, value: newCellValue);
        data[dataRowIndex].time = newCellValue;
        break;
    }
    onChanged?.call(data[dataRowIndex], dataRowIndex);
    updateDataSource();
  }

  void updateDataSource() {
    notifyListeners();
  }
}