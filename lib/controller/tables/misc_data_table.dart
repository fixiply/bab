import 'package:bab/helpers/device_helper.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/misc_page.dart';
import 'package:bab/controller/tables/edit_data_source.dart';
import 'package:bab/controller/tables/edit_sfdatagrid.dart';
import 'package:bab/controller/tables/fields/amount_field.dart';
import 'package:bab/models/misc_model.dart';
import 'package:bab/models/recipe_model.dart';
import 'package:bab/utils/amount.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/utils/localized_text.dart';
import 'package:bab/widgets/containers/error_container.dart';
import 'package:bab/widgets/duration_picker.dart';
import 'package:bab/widgets/image_animate_rotate.dart';
import 'package:bab/widgets/search_text.dart';

// External package
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class MiscDataTable extends StatefulWidget {
  List<MiscModel>? data;
  Widget? title;
  bool inventory;
  bool allowEditing;
  bool allowSorting;
  bool allowAdding;
  bool sort;
  bool loadMore;
  Color? color;
  bool? showCheckboxColumn;
  bool? showAction;
  SelectionMode? selectionMode;
  RecipeModel? recipe;
  final void Function(List<MiscModel> value)? onChanged;
  MiscDataTable({Key? key,
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
    this.showAction = false,
    this.selectionMode = SelectionMode.multiple,
    this.recipe,
    this.onChanged}) : super(key: key);

  @override
  MiscDataTableState createState() => MiscDataTableState();
}

class MiscDataTableState extends State<MiscDataTable> with AutomaticKeepAliveClientMixin {
  late MiscDataSource _dataSource;
  final DataGridController _dataGridController = DataGridController();
  final TextEditingController _searchQueryController = TextEditingController();
  double dataRowHeight = 30;
  List<MiscModel> _selected = [];
  Future<List<MiscModel>>? _data;

  List<MiscModel> get selected => _selected;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _dataSource = MiscDataSource(context,
        showQuantity: widget.data != null,
        showCheckboxColumn: widget.showCheckboxColumn!,
        showAction: widget.allowEditing,
        onEdit: (int rowIndex) {
          _edit(rowIndex);
        },
        onRemove: (int rowIndex) {
          _remove(rowIndex);
        },
        onChanged: (MiscModel value, int dataRowIndex) {
          if (widget.data != null) {
            widget.data![dataRowIndex].amount = value.amount;
            widget.data![dataRowIndex].use = value.use;
            widget.data![dataRowIndex].duration = value.duration;
          }
          widget.onChanged?.call(widget.data ?? [ value ]);
        }
    );
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
              if(_selected.isNotEmpty) TextButton(
                child: const Icon(Icons.delete_outline),
                style: TextButton.styleFrom(
                  backgroundColor: FillColor,
                  shape: const CircleBorder(),
                ),
                onPressed: () {

                },
              )
            ],
          ),
          Flexible(
            child: widget.data == null ? FutureBuilder<List<MiscModel>>(
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

  SfDataGrid _dataGrid(List<MiscModel> data) {
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
      onCellTap: !DeviceHelper.isDesktop && widget.allowEditing ? (DataGridCellTapDetails details) async {
        if (details.column.columnName == 'duration') {
          DataGridRow dataGridRow = _dataSource.rows[details.rowColumnIndex.rowIndex-1];
          var value = _dataSource.getValue(dataGridRow, details.column.columnName);
          var duration = await showDurationPicker(
            context: context,
            initialTime: Duration(minutes: value ??  widget.recipe!.boil),
            maxTime: Duration(minutes: widget.recipe!.boil!),
              // showOkButton: false,
              // onComplete: (duration, context) {
              //   _dataSource.newCellValue = duration.inMinutes;
              //   _dataSource.onCellSubmit(dataGridRow, RowColumnIndex(details.rowColumnIndex.rowIndex-1, details.rowColumnIndex.columnIndex), details.column);
              //   Navigator.pop(context);
              // }
          );
          if (duration != null)  {
            _dataSource.newCellValue = duration.inMinutes;
            _dataSource.onCellSubmit(dataGridRow, RowColumnIndex(details.rowColumnIndex.rowIndex-1, details.rowColumnIndex.columnIndex), details.column);
          }
        }
      } : null,
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
      columns: MiscDataSource.columns(context: context, showQuantity: widget.data != null, showAction: widget.showAction!),
    );
  }

  DataGridController getDataGridController() {
    List<DataGridRow> rows = [];
    for(MiscModel model in _selected) {
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
        _data = Database().getMiscellaneous(searchText: _searchQueryController.value.text, ordered: true);
      });
    }
  }

  _add() async {
    if (widget.allowAdding == true) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return MiscPage(showCheckboxColumn: true);
      })).then((values) {
        if (values != null) {
          if (widget.data != null) {
            for (MiscModel model in values) {
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
          value.insert(0, MiscModel(isEdited: true));
          return value;
        });
      });
    }
  }

  _edit(int rowIndex) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MiscPage(showCheckboxColumn: true, selectionMode: SelectionMode.singleDeselect);
    })).then((values) {
      if (values != null && values?.isNotEmpty) {
        if (widget.data != null && widget.data!.isNotEmpty) {
          values.first.amount = widget.data![rowIndex].amount;
          values.first.use = widget.data![rowIndex].use;
          values.first.duration = widget.data![rowIndex].duration;
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


class MiscDataSource extends EditDataSource {
  List<MiscModel> _data = [];
  final void Function(MiscModel value, int dataRowIndex)? onChanged;
  final void Function(int rowIndex)? onRemove;
  final void Function(int rowIndex)? onEdit;
  /// Creates the employee data source class with required details.
  MiscDataSource(BuildContext context, {List<MiscModel>? data, bool? showQuantity, bool? showCheckboxColumn,  bool? showAction, this.onChanged, this.onRemove, this.onEdit}) : super(context, showQuantity: showQuantity, showAction: showAction, showCheckboxColumn: showCheckboxColumn) {
    if (data != null) buildDataGridRows(data);
  }

  List<MiscModel> get data => _data;
  set data(List<MiscModel> data) => _data = data;

  List<DataGridRow> getDataRows({List<MiscModel>? data}) {
    int index = 0;
    List<MiscModel>? list = data ?? _data;
    return list.map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'uuid', value: e.uuid),
      if (showQuantity == true) DataGridCell<Amount>(columnName: 'amount', value: Amount(e.amount, e.measurement)),
      DataGridCell<dynamic>(columnName: 'name', value: e.name),
      DataGridCell<Misc>(columnName: 'type', value: e.type),
      if (showQuantity == true) DataGridCell<Use>(columnName: 'use', value: e.use),
      if (showQuantity == true) DataGridCell<int>(columnName: 'duration', value: e.duration),
      if (DeviceHelper.isDesktop && showAction == true) DataGridCell<int>(columnName: 'actions', value: index++),
    ])).toList();
  }

  void buildDataGridRows(List<MiscModel> data) {
    this.data = data;
    dataGridRows = getDataRows(data: data);
  }

  @override
  Widget? buildEditWidget(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex, GridColumn column, CellSubmit submitCell) {
    if (column.columnName == 'amount') {
      var value = getValue(dataGridRow, column.columnName);
      newCellValue = value;
      return AmountField(
        value: value.copy(),
        enums: isEnumType('measurement') as List<Measurement>,
        onChanged: (measurement) {
          newCellValue = measurement;
          /// Call [CellSubmit] callback to fire the canSubmitCell and
          /// onCellSubmit to commit the new value in single place.
          submitCell();
        },
      );
    }
    return super.buildEditWidget(dataGridRow, rowColumnIndex, column, submitCell);
  }

  @override
  Future<void> handleLoadMoreRows() async {
    await Future.delayed(const Duration(seconds: 5));
    _addMoreRows(20);
    notifyListeners();
  }

  void _addMoreRows(int count) {
    List<MiscModel>? list = data.skip(dataGridRows.length).toList().take(count).toList();
    dataGridRows.addAll(getDataRows(data: list));
  }

  @override
  bool isNumericType(String columnName) {
    return MiscModel().isNumericType(columnName);
  }

  @override
  List<Enums>? isEnumType(String columnName) {
    return MiscModel().isEnumType(columnName);
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
        } else if (e.value is Amount) {
          if (Measurement.gram == e.value.measurement || Measurement.kilo == e.value.measurement) {
            value = AppLocalizations.of(context)!.weightFormat(e.value.amount);
          } else  if (Measurement.milliliter == e.value.measurement || Measurement.liter == e.value.measurement) {
            value = AppLocalizations.of(context)!.volumeFormat(e.value.amount);
          } else {
            value = AppLocalizations.of(context)!.numberFormat(e.value.amount);
          }
          alignment = Alignment.centerRight;
        } else if (e.value is num) {
          if (e.columnName == 'duration') {
            value = AppLocalizations.of(context)!.durationFormat(e.value);
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
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.all(4),
              child: Text(AppLocalizations.of(context)!.text('not_applicable'), style: TextStyle(color: Theme.of(context).primaryColor))
              // child: Icon(Icons.warning_amber_outlined, size: 18, color: Colors.redAccent.withOpacity(0.3))
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
        child: Text(AppLocalizations.of(context)!.weightFormat(double.parse(summaryValue)) ?? '0',
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
        double? value;
        switch(newCellValue.measurement) {
          case Measurement.gram:
            value = AppLocalizations.of(context)!.gramToKilo(newCellValue.amount);
            break;
          case Measurement.kilo:
            value = AppLocalizations.of(context)!.weight(newCellValue.amount);
            break;
          case Measurement.milliliter:
            value = AppLocalizations.of(context)!.millimeterToLiter(newCellValue.amount);
            break;
          case Measurement.liter:
            value = AppLocalizations.of(context)!.volume(newCellValue.amount);
            break;
          default:
            value = newCellValue.amount;
        }
        dataGridRows[rowColumnIndex.rowIndex].getCells()[columnIndex] =
            DataGridCell<Amount>(columnName: column.columnName, value: Amount(value, newCellValue.measurement));
        data[rowColumnIndex.rowIndex].amount = value;
        data[rowColumnIndex.rowIndex].measurement = newCellValue.measurement;
        break;
      case 'name':
        dataGridRows[rowColumnIndex.rowIndex].getCells()[columnIndex] =
            DataGridCell<String>(columnName: column.columnName, value: newCellValue);
        if (data[rowColumnIndex.rowIndex].name is LocalizedText) {
          data[rowColumnIndex.rowIndex].name.add(AppLocalizations.of(context)!.locale, newCellValue);
        }
        else data[rowColumnIndex.rowIndex].name = newCellValue;
        break;
      case 'type':
        dataGridRows[rowColumnIndex.rowIndex].getCells()[columnIndex] =
            DataGridCell<Misc>(columnName: column.columnName, value: newCellValue);
        data[rowColumnIndex.rowIndex].type = newCellValue;
        break;
      case 'use':
        dataGridRows[rowColumnIndex.rowIndex].getCells()[columnIndex] =
            DataGridCell<Use>(columnName: column.columnName, value: newCellValue);
        data[rowColumnIndex.rowIndex].use = newCellValue;
        break;
      case 'duration':
        dataGridRows[rowColumnIndex.rowIndex].getCells()[columnIndex] =
            DataGridCell<int>(columnName: column.columnName, value: newCellValue);
        data[rowColumnIndex.rowIndex].duration = newCellValue;
        break;
    }
    onChanged?.call(data[rowColumnIndex.rowIndex], rowColumnIndex.rowIndex);
    updateDataSource();
  }

  @override
  void updateDataSource() {
    notifyListeners();
  }

  static List<GridColumn> columns({required BuildContext context, bool showQuantity = false, bool showAction = false}) {
    return [
      GridColumn(
          columnName: 'uuid',
          visible: false,
          label: Container()
      ),
      if (showQuantity == true) GridColumn(
          width: 120,
          columnName: 'amount',
          label: Tooltip(
              message: AppLocalizations.of(context)!.text('amount'),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.centerRight,
                child: Text(AppLocalizations.of(context)!.text('amount'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
            )
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
          columnName: 'type',
          allowEditing: showQuantity == false,
          label: Tooltip(
              message: AppLocalizations.of(context)!.text('type'),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: Text(AppLocalizations.of(context)!.text('type'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
            )
          )
      ),
      if (showQuantity == true) GridColumn(
          columnName: 'use',
          label: Tooltip(
              message: AppLocalizations.of(context)!.text('use'),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: Text(AppLocalizations.of(context)!.text('use'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
            )
          )
      ),
      if (showQuantity == true) GridColumn(
        width: 90,
        columnName: 'duration',
        allowEditing: DeviceHelper.isDesktop,
        label: Tooltip(
            message: AppLocalizations.of(context)!.text('duration'),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.centerRight,
              child: Text(AppLocalizations.of(context)!.text('duration'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
        )
      ),
      if (DeviceHelper.isDesktop && showAction == true) GridColumn(
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

