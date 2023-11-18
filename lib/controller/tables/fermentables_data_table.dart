import 'package:bab/helpers/device_helper.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/fermentables_page.dart';
import 'package:bab/controller/tables/edit_data_source.dart';
import 'package:bab/controller/tables/edit_sfdatagrid.dart';
import 'package:bab/models/fermentable_model.dart';
import 'package:bab/models/recipe_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/helpers/color_helper.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/utils/localized_text.dart';
import 'package:bab/widgets/containers/error_container.dart';
import 'package:bab/widgets/image_animate_rotate.dart';
import 'package:bab/widgets/search_text.dart';

// External package
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';


class FermentablesDataTable extends StatefulWidget {
  List<FermentableModel>? data;
  Widget? title;
  bool inventory;
  bool allowEditing;
  bool allowSorting;
  bool allowAdding;
  bool sort;
  bool loadMore;
  Color? color;
  bool? showCheckboxColumn;
  SelectionMode? selectionMode;
  RecipeModel? recipe;
  final void Function(List<FermentableModel>? value)? onChanged;
  FermentablesDataTable({Key? key,
    this.data,
    this.title,
    this.inventory = false,
    this.allowEditing = true,
    this.allowSorting = true,
    this.allowAdding = false,
    this.sort = true,
    this.loadMore = false,
    this.color,
    this.showCheckboxColumn = true,
    this.selectionMode = SelectionMode.multiple,
    this.recipe,
    this.onChanged}) : super(key: key);

  @override
  FermentablesDataTableState createState() => FermentablesDataTableState();
}

class FermentablesDataTableState extends State<FermentablesDataTable> with AutomaticKeepAliveClientMixin {
  late FermentableDataSource _dataSource;
  final DataGridController _dataGridController = DataGridController();
  final TextEditingController _searchQueryController = TextEditingController();
  double dataRowHeight = 30;
  List<FermentableModel> _selected = [];
  Future<List<FermentableModel>>? _data;

  List<FermentableModel> get selected => _selected;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _dataSource = FermentableDataSource(context,
      showQuantity: widget.data != null,
      showCheckboxColumn: widget.showCheckboxColumn!,
      allowEditing: widget.allowEditing,
      onEdit: (int rowIndex) {
        _edit(rowIndex);
      },
      onRemove: (int rowIndex) {
        _remove(rowIndex);
      },
      onChanged: (FermentableModel value, int dataRowIndex) {
        if (widget.data != null) {
          widget.data![dataRowIndex].amount = value.amount;
          widget.data![dataRowIndex].use = value.use;
        }
        widget.onChanged?.call(widget.data ?? [value]);
      }
    );
    _dataSource.buildDataGridRows(widget.data!);
    if (widget.allowEditing != true) _dataSource.sortedColumns.add(const SortColumnDetails(name: 'amount', sortDirection: DataGridSortDirection.descending));
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.color,
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
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
              const SizedBox(width: 4),
              if(widget.allowEditing == true) TextButton(
                child: const Icon(Icons.add),
                style: TextButton.styleFrom(
                  backgroundColor: FillColor,
                  shape: const CircleBorder(),
                ),
                onPressed: _add,
              ),
            ],
          ),
          Flexible(
            child: widget.data == null ? FutureBuilder<List<FermentableModel>>(
              future: _data,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return _dataGrid(snapshot.data!);
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
            ) : _dataGrid(widget.data!)
          )
        ]
      )
    );
  }

  SfDataGrid _dataGrid(List<FermentableModel> data) {
    if (widget.loadMore) {
      _dataSource.data = data;
      _dataSource.handleLoadMoreRows();
    } else {
      _dataSource.buildDataGridRows(data);
    }
    // _dataSource.notifyListeners();
    return EditSfDataGrid(
      context,
      showCheckboxColumn: widget.showCheckboxColumn!,
      selectionMode: widget.selectionMode!,
      source: _dataSource,
      allowEditing: widget.allowEditing,
      allowSorting: widget.allowSorting,
      controller: getDataGridController(),
      verticalScrollPhysics: const NeverScrollableScrollPhysics(),
      onEdit: (int rowIndex) {
        _edit(rowIndex);
      },
      onRemove: (int rowIndex) {
        _remove(rowIndex);
      },
      onSelectionChanged: (List<DataGridRow> addedRows, List<DataGridRow> removedRows) {
        if (widget.showCheckboxColumn == true) {
          setState(() {
            for(var row in addedRows) {
              final index = _dataSource.rows.indexOf(row);
              _selected.add(data[index]);
            }
            for(var row in removedRows) {
              final index = _dataSource.rows.indexOf(row);
              _selected.remove(data[index]);
            }
          });
        }
      },
      columns: FermentableDataSource.columns(context: context, showQuantity: widget.data != null, allowEditing: widget.allowEditing),
      tableSummaryRows: FermentableDataSource.summaries(context: context, showQuantity: widget.data != null),
    );
  }

  DataGridController getDataGridController() {
    List<DataGridRow> rows = [];
    for(FermentableModel model in _selected) {
      int index = _dataSource.data.indexOf(model);
      if (index != -1) {
        rows.add(_dataSource.dataGridRows[index]);
      }
    }
    _dataGridController.selectedRows = rows;
    return _dataGridController;
  }

  _fetch() async {
    if (widget.data == null) {
      setState(() {
        _data = Database().getFermentables(searchText: _searchQueryController.value.text, ordered: true);
      });
    }
  }

  _add() async {
    if (widget.allowAdding == true) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return FermentablesPage(showCheckboxColumn: true);
      })).then((values) {
        if (values != null) {
          if (widget.data != null) {
            for (FermentableModel model in values) {
              widget.data!.add(model);
            }
            _dataSource.buildDataGridRows(widget.data!);
            _dataSource.notifyListeners();
            widget.onChanged?.call(widget.data!);
          }
        }
      });
    } else if (widget.allowEditing == true) {
      setState(() {
        _data!.then((value) {
          value.insert(0, FermentableModel(isEdited: true));
          return value;
        });
      });
    }
  }

  _edit(int rowIndex) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FermentablesPage(showCheckboxColumn: true, selectionMode: SelectionMode.singleDeselect);
    })).then((values) {
      if (values != null && values!.isNotEmpty) {
        if (widget.data != null && widget.data!.isNotEmpty) {
          values.first.amount = widget.data![rowIndex].amount;
          values.first.use = widget.data![rowIndex].use;
          widget.data![rowIndex] = values.first;
          _dataSource.buildDataGridRows(widget.data!);
          _dataSource.notifyListeners();
          widget.onChanged?.call(widget.data!);
        }
      }
    });
  }

  _remove(int rowIndex) async {
    widget.data!.removeAt(rowIndex);
    _dataSource.buildDataGridRows(widget.data!);
    _dataSource.notifyListeners();
    widget.onChanged?.call(widget.data!);
  }
}

class FermentableDataSource extends EditDataSource {
  List<FermentableModel> _data = [];
  final void Function(FermentableModel value, int dataRowIndex)? onChanged;
  final void Function(int rowIndex)? onRemove;
  final void Function(int rowIndex)? onEdit;
  /// Creates the employee data source class with required details.
  FermentableDataSource(BuildContext context, {List<FermentableModel>? data, bool? showQuantity, bool? showCheckboxColumn,  bool? allowEditing, this.onChanged, this.onRemove, this.onEdit}) : super(context, showQuantity: showQuantity, allowEditing: allowEditing, showCheckboxColumn: showCheckboxColumn) {
    if (data != null) buildDataGridRows(data);
  }

  List<FermentableModel> get data => _data;
  set data(List<FermentableModel> data) => _data = data;

  List<DataGridRow> getDataRows({List<FermentableModel>? data}) {
    int index = 0;
    List<FermentableModel>? list = data ?? _data;
    return list.map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'uuid', value: e.uuid),
      if (showQuantity == true) DataGridCell<double>(columnName: 'amount', value: e.amount),
      DataGridCell<dynamic>(columnName: 'name', value: e.name),
      DataGridCell<dynamic>(columnName: 'origin', value: e.origin),
      DataGridCell<Type>(columnName: 'type', value: e.type),
      if (showQuantity == true) DataGridCell<Method>(columnName: 'method', value: e.use),
      DataGridCell<double>(columnName: 'efficiency', value: e.efficiency),
      DataGridCell<int>(columnName: 'color', value: e.ebc),
      if (DeviceHelper.isDesktop && allowEditing == true) DataGridCell<int>(columnName: 'actions', value: index++),
    ])).toList();
  }

  void buildDataGridRows(List<FermentableModel> data) {
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
    List<FermentableModel>? list = data.skip(dataGridRows.length).toList().take(count).toList();
    dataGridRows.addAll(getDataRows(data: list));
  }

  @override
  dynamic getValue(DataGridRow dataGridRow, String columnName) {
    var value = super.getValue(dataGridRow, columnName);
    if (value != null && columnName == 'amount') {
      double? weight = AppLocalizations.of(context)!.weight(value * 1000, unit: Unit.kilo);
      return weight!.toPrecision(2);
    }
    return value;
  }

  @override
  String? suffixText(String columnName) {
    if (columnName == 'amount') {
      return AppLocalizations.of(context)!.weightSuffix(unit: Unit.kilo);
    }
    return null;
  }

  @override
  bool isNumericType(String columnName) {
    return FermentableModel().isNumericType(columnName);
  }

  @override
  List<Enums>? isEnumType(String columnName) {
    return FermentableModel().isEnumType(columnName);
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
            value = AppLocalizations.of(context)!.kiloWeightFormat(e.value);
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
              margin: const EdgeInsets.all(4),
              child: Icon(Icons.warning_amber_outlined, size: 18, color: Colors.redAccent.withOpacity(0.3))
            );
          }
        }
        if (e.columnName == 'color') {
          Color? color = ColorHelper.color(e.value);
          if (color != null) {
            return Container(
              margin: const EdgeInsets.all(4),
              color: color,
              child: Center(child: Text(value ?? '', style: const TextStyle(color: Colors.white, fontSize: 14)))
            );
          }
          return Container();
        }
        if (e.columnName == 'origin') {
          if (value != null) {
            return Container(
              margin: const EdgeInsets.all(4),
              child: Center(child: Text(LocalizedText.emoji(value),
                  style: const TextStyle(fontSize: 16, fontFamily: 'Emoji')))
            );
          }
        }
        if (e.columnName == 'actions') {
          return PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: AppLocalizations.of(context)!.text('options'),
            onSelected: (value) async {
              if (value == 'edit') {
                onEdit?.call(e.value);
              } else if (value == 'remove') {
                onRemove?.call(e.value);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem(
                value: 'edit',
                child: Text(AppLocalizations.of(context)!.text('replace')),
              ),
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
          child: tooltipText(value),
        );
      }).toList()
    );
  }

  @override
  Widget? buildTableSummaryCellWidget(GridTableSummaryRow summaryRow, GridSummaryColumn? summaryColumn, RowColumnIndex rowColumnIndex, String summaryValue) {
    if (summaryValue.isNotEmpty) {
      return Container(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.centerRight,
        child: Text(AppLocalizations.of(context)!.kiloWeightFormat(double.parse(summaryValue)) ?? '0',
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500)
        ),
      );
    }
    return null;
  }

  @override
  Future<void> onCellSubmit(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex, GridColumn column) async {
    final dynamic oldValue = dataGridRow.getCells().firstWhere((DataGridCell dataGridCell) =>
    dataGridCell.columnName == column.columnName).value ?? '';
    if (oldValue == newCellValue) {
      return;
    }
    int columnIndex = showCheckboxColumn == true ? rowColumnIndex.columnIndex-1 : rowColumnIndex.columnIndex;
    switch(column.columnName) {
      case 'amount':
        double? value = AppLocalizations.of(context)!.gram(newCellValue, unit: Unit.kilo);
        dataGridRows[rowColumnIndex.rowIndex].getCells()[columnIndex] =
            DataGridCell<double>(columnName: column.columnName, value: value);
        _data[rowColumnIndex.rowIndex].amount = value;
        break;
      case 'name':
        dataGridRows[rowColumnIndex.rowIndex].getCells()[columnIndex] =
            DataGridCell<String>(columnName: column.columnName, value: newCellValue);
        if (_data[rowColumnIndex.rowIndex].name is LocalizedText) {
          _data[rowColumnIndex.rowIndex].name.add(AppLocalizations.of(context)!.locale, newCellValue);
        }
        else _data[rowColumnIndex.rowIndex].name = newCellValue;
        break;
      case 'origin':
        dataGridRows[rowColumnIndex.rowIndex].getCells()[columnIndex] =
            DataGridCell<String>(columnName: column.columnName, value: newCellValue);
        _data[rowColumnIndex.rowIndex].name = newCellValue;
        break;
      case 'type':
        dataGridRows[rowColumnIndex.rowIndex].getCells()[columnIndex] =
            DataGridCell<Type>(columnName: column.columnName, value: newCellValue);
        _data[rowColumnIndex.rowIndex].type = newCellValue;
        break;
      case 'method':
        dataGridRows[rowColumnIndex.rowIndex].getCells()[columnIndex] =
            DataGridCell<Method>(columnName: column.columnName, value: newCellValue);
        _data[rowColumnIndex.rowIndex].use = newCellValue;
        break;
      case 'efficiency':
        dataGridRows[rowColumnIndex.rowIndex].getCells()[columnIndex] =
            DataGridCell<double>(columnName: column.columnName, value: newCellValue);
        _data[rowColumnIndex.rowIndex].efficiency = newCellValue;
        break;
      case 'color':
        dataGridRows[rowColumnIndex.rowIndex].getCells()[columnIndex] =
            DataGridCell<double>(columnName: column.columnName, value: newCellValue);
        _data[rowColumnIndex.rowIndex].ebc = newCellValue;
        break;
    }
    onChanged?.call(_data[rowColumnIndex.rowIndex], rowColumnIndex.rowIndex);
    updateDataSource();
  }

  @override
  void updateDataSource() {
    notifyListeners();
  }

  static List<GridColumn> columns({required BuildContext context, bool showQuantity = false, bool allowEditing = false}) {
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
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.centerRight,
              child: Text(AppLocalizations.of(context)!.text('amount'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
          columnName: 'name',
          allowEditing: showQuantity == false,
          label: Container(
              padding: const EdgeInsets.all(8.0),
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
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context)!.text('origin'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
          columnName: 'type',
          allowEditing: showQuantity == false,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(AppLocalizations.of(context)!.text('type'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      if (showQuantity == true) GridColumn(
          columnName: 'method',
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(AppLocalizations.of(context)!.text('method'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
          width: 90,
          columnName: 'efficiency',
          allowEditing: showQuantity == false,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.centerRight,
              child: Text(AppLocalizations.of(context)!.text('yield'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
          width: 90,
          columnName: 'color',
          allowEditing: showQuantity == false,
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(AppLocalizations.of(context)!.colorUnit, style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
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

  static List<GridTableSummaryRow> summaries({required BuildContext context, bool showQuantity = false}) {
    return <GridTableSummaryRow>[
      if (showQuantity == true) GridTableSummaryRow(
        showSummaryInRow: false,
        columns: <GridSummaryColumn>[
          const GridSummaryColumn(
            name: 'amount',
            columnName: 'amount',
            summaryType: GridSummaryType.sum
          ),
        ],
        position: GridTableSummaryRowPosition.bottom
      ),
    ];
  }
}

