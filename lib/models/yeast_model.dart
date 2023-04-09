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

enum Yeast with Enums { liquid, dry, slant, culture;
  List<Enum> get enums => [ liquid, dry, slant, culture ];
}

extension DoubleParsing on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

class YeastModel<T> extends Model {
  Status? status;
  dynamic? name;
  String? reference;
  String? laboratory;
  Fermentation? type;
  Yeast? form;
  double? amount;
  double? cells;
  double? tempmin;
  double? tempmax;
  double? attmin;
  double? attmax;
  dynamic? notes;

  YeastModel({
    String? uuid,
    DateTime? inserted_at,
    DateTime? updated_at,
    String? creator,
    bool? isEdited,
    bool? isSelected,
    this.status = Status.publied,
    this.name,
    this.reference,
    this.laboratory,
    this.type = Fermentation.hight,
    this.form = Yeast.dry,
    this.amount,
    this.cells,
    this.tempmin,
    this.tempmax,
    this.attmin,
    this.attmax,
    this.notes,
  }) : super(uuid: uuid, inserted_at: inserted_at, updated_at: updated_at, creator: creator, isEdited: isEdited, isSelected: isSelected);

  void fromMap(Map<String, dynamic> map) {
    super.fromMap(map);
    this.status = Status.values.elementAt(map['status']);
    this.name = LocalizedText.deserialize(map['name']);
    this.name = LocalizedText.deserialize(map['name']);
    this.reference = map['product'];
    this.laboratory = map['laboratory'];
    this.type = Fermentation.values.elementAt(map['type']);
    this.form = Yeast.values.elementAt(map['form']);
    // if (map['amount'] != null) this.amount = map['amount'].toDouble();
    if (map['cells'] != null) this.cells = map['cells'].toDouble();
    if (map['min_temp'] != null) this.tempmin = map['min_temp'].toDouble();
    if (map['max_temp'] != null) this.tempmin = map['max_temp'].toDouble();
    if (map['min_attenuation'] != null) this.attmin = map['min_attenuation'].toDouble();
    if (map['max_attenuation'] != null) this.attmax = map['max_attenuation'].toDouble();
    this.notes = LocalizedText.deserialize(map['notes']);
  }

  Map<String, dynamic> toMap({bool persist : false}) {
    Map<String, dynamic> map = super.toMap(persist: persist);
    map.addAll({
      'status': this.status!.index,
      'name': LocalizedText.serialize(this.name),
      'product': this.reference,
      'laboratory': this.laboratory,
      'type': this.type!.index,
      'form': this.form!.index,
      // 'amount': this.amount,
      'cells': this.cells,
      'min_temp': this.tempmin,
      'max_temp': this.tempmax,
      'min_attenuation': this.attmin,
      'max_attenuation': this.attmax,
      'notes': LocalizedText.serialize(this.notes),
    });
    return map;
  }

  YeastModel copy() {
    return YeastModel(
      uuid: this.uuid,
      inserted_at: this.inserted_at,
      updated_at: this.updated_at,
      creator: this.creator,
      status: this.status,
      name: this.name,
      reference: this.reference,
      laboratory: this.laboratory,
      type: this.type,
      form: this.form,
      amount: this.amount,
      cells: this.cells,
      tempmin: this.tempmin,
      tempmax: this.tempmax,
      attmin: this.attmin,
      attmax: this.attmax,
      notes: this.notes,
    );
  }

  // ignore: hash_and_equals
  bool operator ==(other) {
    return (other is YeastModel && other.uuid == uuid);
  }

  @override
  String toString() {
    return 'YeastModel: $name, UUID: $uuid';
  }

  double? get attenuation {
    if (this.attmin != null && this.attmax != null) {
      return (this.attmin! + this.attmax!) / 2;
    }
    return null;
  }

  /// Returns the pitching rate, based on the given conditions.
  ///
  /// The `og` argument is relative to the original gravity 1.xxx.
  double pitchingRate(double? og) {
    if (og != null) {
      if (type == Fermentation.low) {
        if (og < 1.060) {
          return 1.50;
        } else return 2.0;
      } else if (type == Fermentation.hight) {
        if (og < 1.060) {
          return 0.75;
        } else return 1.0;
      }
    }
    return 0.35;
  }

  /// Returns the final density, based on the given conditions.
  ///
  /// The `og` argument is relative to the original gravity 1.xxx.
  double density(double? og) {
    return FormulaHelper.fg(og, attenuation);
  }

  @override
  bool isNumericType(String columnName) {
    return columnName == 'amount' || columnName == 'attenuation';
  }

  @override
  bool isTextType(String columnName) {
    return columnName == 'name' || columnName == 'notes';
  }

  @override
  List<Enums>? isEnumType(String columnName) {
    if (columnName == 'type') {
      return Fermentation.values;
    } else if (columnName == 'form') {
      return Yeast.values;
    }
    return null;
  }

  static List<YeastModel> merge(List<Quantity>? quantities, List<YeastModel> yeasts) {
    List<YeastModel> list = [];
    if (quantities != null && yeasts != null) {
      for (Quantity quantity in quantities) {
        for (YeastModel yeast in yeasts) {
          if (quantity.uuid == yeast.uuid) {
            YeastModel model = yeast.copy();
            model.amount = quantity.amount;
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
      if (data is YeastModel) {
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

  static List<YeastModel> deserialize(dynamic data) {
    List<YeastModel> values = [];
    if (data != null) {
      if (data is List) {
        for(final value in data) {
          values.addAll(deserialize(value));
        }
      } else {
        YeastModel model = new YeastModel();
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
          columnName: 'reference',
          allowEditing: showQuantity == false,
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context)!.text('reference'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
          columnName: 'laboratory',
          allowEditing: showQuantity == false,
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context)!.text('laboratory'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
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
          width: 90,
          columnName: 'attenuation',
          allowEditing: false,
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.centerRight,
              child: Text(AppLocalizations.of(context)!.text('attenuation'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
    ];
  }
}

class YeastDataSource extends EditDataSource {
  List<YeastModel> data = [];
  final void Function(YeastModel value, int dataRowIndex)? onChanged;
  /// Creates the employee data source class with required details.
  YeastDataSource(BuildContext context, {List<YeastModel>? data, bool? showQuantity, bool? showCheckboxColumn, this.onChanged}) : super(context, showQuantity: showQuantity!, showCheckboxColumn: showCheckboxColumn!) {
    if (data != null) buildDataGridRows(data);
  }

  void buildDataGridRows(List<YeastModel> data) {
    this.data = data;
    dataGridRows = data.map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'uuid', value: e.uuid),
      if (showQuantity == true) DataGridCell<double>(columnName: 'amount', value: e.amount),
      DataGridCell<dynamic>(columnName: 'name', value: e.name),
      DataGridCell<dynamic>(columnName: 'reference', value: e.reference),
      DataGridCell<dynamic>(columnName: 'laboratory', value: e.laboratory),
      DataGridCell<Fermentation>(columnName: 'type', value: e.type),
      DataGridCell<Yeast>(columnName: 'form', value: e.form),
      DataGridCell<double>(columnName: 'attenuation', value: e.attenuation)
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
  bool isNumericType(GridColumn column) {
    return YeastModel().isNumericType(column.columnName);
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
            } else if (e.columnName == 'attenuation') {
              value = AppLocalizations.of(context)!.percentFormat(e.value);
            } else if (e.columnName == 'duration') {
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
      case 'reference':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<String>(columnName: column.columnName, value: newCellValue);
        data[dataRowIndex].reference = newCellValue;
        break;
      case 'laboratory':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<String>(columnName: column.columnName, value: newCellValue);
        data[dataRowIndex].laboratory = newCellValue;
        break;
      case 'type':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<Fermentation>(columnName: column.columnName, value: newCellValue);
        data[dataRowIndex].type = newCellValue;
        break;
      case 'form':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<Yeast>(columnName: column.columnName, value: newCellValue);
        data[dataRowIndex].form = newCellValue;
        break;
    }
    onChanged?.call(data[dataRowIndex], dataRowIndex);
    updateDataSource();
  }

  void updateDataSource() {
    notifyListeners();
  }
}
