import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/tanks_page.dart';
import 'package:bb/controller/tables/edit_data_source.dart';
import 'package:bb/controller/tables/edit_sfdatagrid.dart';
import 'package:bb/models/equipment_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/helpers/color_helper.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/utils/localized_text.dart';
import 'package:bb/utils/quantity.dart';
import 'package:bb/widgets/containers/error_container.dart';
import 'package:bb/widgets/image_animate_rotate.dart';
import 'package:bb/widgets/search_text.dart';

// External package
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';


class TanksDataTable extends StatefulWidget {
  List<Quantity>? data;
  Widget? title;
  bool allowEditing;
  bool allowSorting;
  bool allowAdding;
  bool sort;
  bool loadMore;
  Color? color;
  bool? showCheckboxColumn;
  SelectionMode? selectionMode;
  TanksDataTable({Key? key,
    this.data,
    this.title,
    this.allowEditing = true,
    this.allowSorting = true,
    this.allowAdding = false,
    this.sort = true,
    this.loadMore = false,
    this.color,
    this.showCheckboxColumn = true,
    this.selectionMode = SelectionMode.multiple}) : super(key: key);
  TanksDataTableState createState() => new TanksDataTableState();
}

class TanksDataTableState extends State<TanksDataTable> with AutomaticKeepAliveClientMixin {
  late TankDataSource _dataSource;
  final DataGridController _dataGridController = DataGridController();
  final TextEditingController _searchQueryController = TextEditingController();
  double dataRowHeight = 30;
  List<EquipmentModel> _selected = [];
  Future<List<EquipmentModel>>? _data;

  List<EquipmentModel> get selected => _selected;

  @override
  bool get wantKeepAlive => true;

  void initState() {
    super.initState();
    _dataSource = TankDataSource(context,
      showCheckboxColumn: widget.showCheckboxColumn!,
      onChanged: (EquipmentModel value, int dataRowIndex) {

      }
    );
    if (widget.allowEditing != true) _dataSource.sortedColumns.add(const SortColumnDetails(name: 'name', sortDirection: DataGridSortDirection.ascending));
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.color,
      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(child: widget.title ?? (widget.data == null ? SearchText(
                _searchQueryController,
                () {  _fetch(); }
              ) : Container())),
              SizedBox(width: 4),
              if(widget.allowEditing == true) TextButton(
                child: Icon(Icons.add),
                style: TextButton.styleFrom(
                  backgroundColor: FillColor,
                  shape: CircleBorder(),
                ),
                onPressed: _add,
              ),
            ],
          ),
          Flexible(
            child: SfDataGridTheme(
              data: SfDataGridThemeData(),
              child: FutureBuilder<List<EquipmentModel>>(
                future: _data,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (widget.loadMore) {
                      _dataSource.data = snapshot.data!;
                      _dataSource.handleLoadMoreRows();
                    } else {
                      _dataSource.buildDataGridRows(snapshot.data!);
                    }
                    _dataSource.notifyListeners();
                    return EditSfDataGrid(
                      context,
                      showCheckboxColumn: widget.showCheckboxColumn!,
                      selectionMode: widget.selectionMode!,
                      source: _dataSource,
                      allowEditing: widget.allowEditing,
                      allowSorting: widget.allowSorting,
                      controller: getDataGridController(),
                      verticalScrollPhysics: const NeverScrollableScrollPhysics(),
                      onRemove: (DataGridRow row, int rowIndex) {
                        setState(() {
                          _data!.then((value) => value.removeAt(rowIndex));
                        });
                        widget.data!.removeAt(rowIndex);
                        // widget.onChanged?.call(widget.data!);
                      },
                      onSelectionChanged: (List<DataGridRow> addedRows, List<DataGridRow> removedRows) {
                        if (widget.showCheckboxColumn == true) {
                          setState(() {
                            for(var row in addedRows) {
                              final index = _dataSource.rows.indexOf(row);
                              _selected.add(snapshot.data![index]);
                            }
                            for(var row in removedRows) {
                              final index = _dataSource.rows.indexOf(row);
                              _selected.remove(snapshot.data![index]);
                            }
                          });
                        }
                      },
                      columns: TankDataSource.columns(context: context, showQuantity: widget.data != null),
                    );
                  }
                  if (snapshot.hasError) {
                    return ErrorContainer(snapshot.error.toString());
                  }
                  return Center(
                      child: ImageAnimateRotate(
                        child: Image.asset('assets/images/logo.png', width: 60, height: 60, color: Theme.of(context).primaryColor),
                      )
                  );
                }
              ),
            )
          )
        ]
      )
    );
  }

  DataGridController getDataGridController() {
    List<DataGridRow> rows = [];
    for(EquipmentModel model in _selected) {
      int index = _dataSource.data.indexOf(model);
      if (index != -1) {
        rows.add(_dataSource.dataGridRows[index]);
      }
    }
    _dataGridController.selectedRows = rows;
    return _dataGridController;
  }

  _fetch() async {
    setState(() {
      _data = Database().getEquipments(type: Equipment.tank, searchText: _searchQueryController.value.text, ordered: true);
    });
  }

  _add() async {
    if (widget.allowAdding == true) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return TanksPage(showCheckboxColumn: true);
      })).then((values) {
        if (values != null) {
          setState(() {
            _data!.then((value) => value.addAll(values));
          });
          if (widget.data != null) {
            for(EquipmentModel model in values) {
              widget.data!.add(Quantity(uuid: model.uuid));
            }
            // widget.onChanged?.call(widget.data!);
          }
        }
      });
    } else if (widget.allowEditing == true) {
      setState(() {
        _data!.then((value) {
          value.insert(0, EquipmentModel(isEdited: true));
          return value;
        });
      });
    }
  }

  _remove() async {
    if (widget.allowEditing == false) {

    } else {

    }
  }

  _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 10)
        )
    );
  }
}

class TankDataSource extends EditDataSource {
  List<EquipmentModel> _data = [];
  final void Function(EquipmentModel value, int dataRowIndex)? onChanged;
  /// Creates the employee data source class with required details.
  TankDataSource(BuildContext context, {List<EquipmentModel>? data, bool? showCheckboxColumn, this.onChanged}) : super(context, showCheckboxColumn: showCheckboxColumn!) {
    if (data != null) buildDataGridRows(data);
  }

  List<EquipmentModel> get data => _data;
  set data(List<EquipmentModel> data) => _data = data;

  List<DataGridRow> getDataRows({List<EquipmentModel>? data}) {
    List<EquipmentModel>? list = data ?? _data;
    return list.map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'uuid', value: e.uuid),
      DataGridCell<String>(columnName: 'name', value: e.name),
      DataGridCell<double>(columnName: 'volume', value: e.volume),
      DataGridCell<double>(columnName: 'size', value: e.mash_volume),
      DataGridCell<double>(columnName: 'efficiency', value: e.efficiency),
      DataGridCell<double>(columnName: 'absorption', value: e.absorption),
      DataGridCell<double>(columnName: 'lost_volume', value: e.lost_volume),
    ])).toList();
  }

  void buildDataGridRows(List<EquipmentModel> data) {
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
    List<EquipmentModel>? list = data.skip(dataGridRows.length).toList().take(count).toList();
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
  String? suffixText(String columnName) {
    if (columnName == 'amount') {
      return AppLocalizations.of(context)!.weightSuffix(weight: Weight.kilo);
    }
    return null;
  }

  @override
  bool isNumericType(String columnName) {
    return EquipmentModel().isNumericType(columnName);
  }

  @override
  List<Enums>? isEnumType(String columnName) {
    return EquipmentModel().isEnumType(columnName);
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
          } else if (e.value is DateTime) {
            alignment = Alignment.centerRight;
            value = AppLocalizations.of(context)!.datetimeFormat(e.value);
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
                color: ColorHelper.color(e.value),
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
  Future<void> onCellSubmit(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex, GridColumn column) async {
    final dynamic oldValue = dataGridRow.getCells().firstWhere((DataGridCell dataGridCell) =>
    dataGridCell.columnName == column.columnName).value ?? '';
    final int dataRowIndex = dataGridRows.indexOf(dataGridRow);
    if (dataRowIndex == -1 || oldValue == newCellValue) {
      return;
    }
    int columnIndex = showCheckboxColumn ? rowColumnIndex.columnIndex-1 : rowColumnIndex.columnIndex;
    switch(column.columnName) {
      case 'name':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<String>(columnName: column.columnName, value: newCellValue);
        _data[dataRowIndex].name = newCellValue;
        break;
      case 'volume':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<double>(columnName: column.columnName, value: newCellValue);
        _data[dataRowIndex].volume = AppLocalizations.of(context)!.gram(newCellValue * 1000, weight: Weight.kilo);
        break;
      case 'size':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<double>(columnName: column.columnName, value: newCellValue);
        _data[dataRowIndex].mash_volume = AppLocalizations.of(context)!.gram(newCellValue * 1000, weight: Weight.kilo);
        break;
      case 'efficiency':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<double>(columnName: column.columnName, value: newCellValue);
        _data[dataRowIndex].efficiency = AppLocalizations.of(context)!.gram(newCellValue * 1000, weight: Weight.kilo);
        break;
      case 'absorption':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<double>(columnName: column.columnName, value: newCellValue);
        _data[dataRowIndex].absorption = AppLocalizations.of(context)!.gram(newCellValue * 1000, weight: Weight.kilo);
        break;
      case 'lost_volume':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<double>(columnName: column.columnName, value: newCellValue);
        _data[dataRowIndex].lost_volume = AppLocalizations.of(context)!.gram(newCellValue * 1000, weight: Weight.kilo);
        break;
    }
    onChanged?.call(_data[dataRowIndex], dataRowIndex);
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
          columnName: 'name',
          allowEditing: showQuantity == false,
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context)!.text('name'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
          width: 90,
          columnName: 'volume',
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.centerRight,
              child: Text(AppLocalizations.of(context)!.text('tank_volume'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
          width: 90,
          columnName: 'size',
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.centerRight,
              child: Text(AppLocalizations.of(context)!.text('mash_volume'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
          width: 90,
          columnName: 'efficiency',
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.centerRight,
              child: Text(AppLocalizations.of(context)!.text('mash_efficiency'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
          width: 90,
          columnName: 'absorption',
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.centerRight,
              child: Text(AppLocalizations.of(context)!.text('absorption'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
          width: 90,
          columnName: 'lost_volume',
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.centerRight,
              child: Text(AppLocalizations.of(context)!.text('lost_volume'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
    ];
  }
}

