import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/tables/edit_data_source.dart';
import 'package:bb/helpers/formula_helper.dart';
import 'package:bb/models/model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/localized_text.dart';
import 'package:bb/utils/quantity.dart';
import 'package:intl/intl.dart';

// External package
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

enum Hop with Enums { leaf, pellet, plug, other;
  List<Enum> get enums => [ leaf, pellet, plug, other ];
}

enum Type with Enums { aroma, bittering, both;
  List<Enum> get enums => [ aroma, bittering, both ];
}
enum Use with Enums { mash, first_wort, boil, aroma, dry_hop;
  List<Enum> get enums => [ mash, first_wort, boil, aroma, dry_hop ];
}

extension Ex on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

class HopModel<T> extends Model {
  Status? status;
  dynamic? name;
  String? origin;
  double? alpha;
  double? beta;
  double? amount;
  Hop? form;
  Type? type;
  Use? use;
  int? duration;
  dynamic? notes;

  HopModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    bool? isEdited,
    bool? isSelected,
    this.status = Status.publied,
    this.name,
    this.origin,
    this.alpha,
    this.beta,
    this.amount,
    this.form = Hop.pellet,
    this.type = Type.both,
    this.use = Use.boil,
    this.duration,
    this.notes,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator, isEdited: isEdited, isSelected: isSelected);

  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    this.name = LocalizedText.deserialize(map['name']);
    this.origin = map['origin'];
    if (map['alpha'] != null) this.alpha = map['alpha'].toDouble();
    if (map['beta'] != null) this.beta = map['beta'].toDouble();
    // if (map['amount'] != null) this.amount = map['amount'].toDouble();
    this.form = Hop.values.elementAt(map['form']);
    this.type = Type.values.elementAt(map['type']);
    // if (map['use'] != null) this.use = HopUse.values.elementAt(map['use']);
    // this.duration = map['duration'];
    this.notes = LocalizedText.deserialize(map['notes']);
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'name': LocalizedText.serialize(this.name),
      'origin': this.origin,
      'alpha': this.alpha,
      'beta': this.beta,
      // 'amount': this.amount,
      'form': this.form!.index,
      'type': this.type!.index,
      // 'use': this.use!.index,
      // 'duration': this.duration,
      'notes': LocalizedText.serialize(this.notes),
    });
    return map;
  }

  HopModel copy() {
    return HopModel(
      uuid: this.uuid,
      inserted_at: this.inserted_at,
      updated_at: this.updated_at,
      creator: this.creator,
      status: this.status,
      name: this.name,
      origin: this.origin,
      alpha: this.alpha,
      beta: this.beta,
      amount: this.amount,
      form: this.form,
      type: this.type,
      use: this.use,
      duration: this.duration,
      notes: this.notes,
    );
  }

  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is HopModel && other.uuid == uuid);
  }

  @override
  String toString() {
    return 'HopModel: $name, UUID: $uuid';
  }

  /// Returns the bitterness index, based on the given conditions.
  ///
  /// The `amount` argument is relative to the amount of hops in grams.
  ///
  /// The `alpha` argument is relative to the hops alpha acid.
  ///
  /// The `og` argument is relative to the original gravity.
  ///
  /// The `duration` argument is relative to the boil duration in minute.
  ///
  /// The `volume` argument is relative to the final volume.
  double ibu(double? og, int? duration, double? volume, {double? maximum})  {
    return FormulaHelper.ibu(this.amount, this.alpha, og, this.duration, volume, maximum: maximum);
  }

  @override
  bool isNumericType(String columnName) {
    return columnName == 'amount' || columnName == 'alpha' || columnName == 'duration';
  }

  @override
  bool isTextType(String columnName) {
    return columnName == 'name' || columnName == 'notes';
  }

  @override
  List<Enums>? isEnumType(String columnName) {
    if (columnName == 'form') {
      return Hop.values;
    } else if (columnName == 'type') {
      return Type.values;
    } else if (columnName == 'use') {
      return Use.values;
    }
    return null;
  }

  static List<HopModel> merge(List<Quantity>? quantities, List<HopModel> hops) {
    List<HopModel> list = [];
    if (quantities != null && hops != null) {
      for (Quantity quantity in quantities) {
        for (HopModel hop in hops) {
          if (quantity.uuid == hop.uuid) {
            HopModel model = hop.copy();
            model.amount = quantity.amount;
            model.duration = quantity.duration;
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
      if (data is HopModel) {
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

  static List<HopModel> deserialize(dynamic data) {
    List<HopModel> values = [];
    if (data != null) {
      if (data is List) {
        for(final value in data) {
          values.addAll(deserialize(value));
        }
      } else {
        HopModel model = new HopModel();
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
          width: 90,
          columnName: 'alpha',
          allowEditing: showQuantity == false,
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.centerRight,
              child: Text(AppLocalizations.of(context)!.text('alpha'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
          columnName: 'form',
          allowEditing: showQuantity == false,
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(AppLocalizations.of(context)!.text('form'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
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
          columnName: 'duration',
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.centerRight,
              child: Text(AppLocalizations.of(context)!.text('duration'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
    ];
  }
}

class HopDataSource extends EditDataSource {
  List<HopModel> data = [];
  final void Function(HopModel value, int dataRowIndex)? onChanged;
  /// Creates the employee data source class with required details.
  HopDataSource(BuildContext context, {List<HopModel>? data, bool? showQuantity, bool? showCheckboxColumn, this.onChanged}) : super(context, showQuantity: showQuantity!, showCheckboxColumn: showCheckboxColumn!) {
    if (data != null) buildDataGridRows(data);
  }

  void buildDataGridRows(List<HopModel> data) {
    this.data = data;
    dataGridRows = data.map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'uuid', value: e.uuid),
      if (showQuantity == true) DataGridCell<double>(columnName: 'amount', value: e.amount),
      DataGridCell<dynamic>(columnName: 'name', value: e.name),
      DataGridCell<dynamic>(columnName: 'origin', value: e.origin),
      DataGridCell<double>(columnName: 'alpha', value: e.alpha),
      DataGridCell<Hop>(columnName: 'form', value: e.form),
      DataGridCell<Type>(columnName: 'type', value: e.type),
      if (showQuantity == true) DataGridCell<Use>(columnName: 'use', value: e.use),
      if (showQuantity == true) DataGridCell<int>(columnName: 'duration', value: e.duration),
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
    return HopModel().isNumericType(column.columnName);
  }

  @override
  List<Enums>? isEnumType(GridColumn column) {
    return HopModel().isEnumType(column.columnName);
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
            } else if (e.columnName == 'alpha') {
              value = AppLocalizations.of(context)!.percentFormat(e.value);
            } else if (e.columnName == 'duration') {
              var use = row.getCells().firstWhere((DataGridCell dataGridCell) => dataGridCell.columnName == 'use').value;
              value = AppLocalizations.of(context)!.durationFormat(use == Use.dry_hop ? e.value * 1440 : e.value);
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
      case 'origin':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<String>(columnName: column.columnName, value: newCellValue);
        data[dataRowIndex].name = newCellValue;
        break;
      case 'alpha':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<double>(columnName: column.columnName, value: newCellValue);
        data[dataRowIndex].alpha = newCellValue;
        break;
      case 'form':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<Hop>(columnName: column.columnName, value: newCellValue);
        data[dataRowIndex].form = newCellValue;
        break;
      case 'type':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<Type>(columnName: column.columnName, value: newCellValue);
        data[dataRowIndex].type = newCellValue;
        break;
      case 'use':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<Use>(columnName: column.columnName, value: newCellValue);
        data[dataRowIndex].use = newCellValue;
        break;
      case 'duration':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<int>(columnName: column.columnName, value: newCellValue);
        data[dataRowIndex].duration = newCellValue;
        break;
    }
    onChanged?.call(data[dataRowIndex], dataRowIndex);
    updateDataSource();
  }

  void updateDataSource() {
    notifyListeners();
  }
}
