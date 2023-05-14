import 'package:bb/helpers/formula_helper.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/tables/edit_data_source.dart';
import 'package:bb/controller/tables/edit_sfdatagrid.dart';
import 'package:bb/controller/yeasts_page.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:bb/models/yeast_model.dart';
import 'package:bb/utils/app_localizations.dart';
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

class YeastsDataTable extends StatefulWidget {
  List<YeastModel>? data;
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
  ReceiptModel? receipt;
  final void Function(List<YeastModel> value)? onChanged;
  YeastsDataTable({Key? key,
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
    this.receipt,
    this.onChanged}) : super(key: key);
  YeastsDataTableState createState() => new YeastsDataTableState();
}

class YeastsDataTableState extends State<YeastsDataTable> with AutomaticKeepAliveClientMixin {
  late YeastDataSource _dataSource;
  final DataGridController _dataGridController = DataGridController();
  final TextEditingController _searchQueryController = TextEditingController();
  double dataRowHeight = 30;
  List<YeastModel> _selected = [];
  Future<List<YeastModel>>? _data;

  List<YeastModel> get selected => _selected;

  @override
  bool get wantKeepAlive => true;

  void initState() {
    super.initState();
    _dataSource = YeastDataSource(context,
        showQuantity: widget.data != null,
        showCheckboxColumn: widget.showCheckboxColumn!,
        onChanged: (YeastModel value, int dataRowIndex) {
          var amount = value.amount;
          if (value.form == Yeast.dry || value.form == Yeast.liquid) {
            if (amount == null) {
              amount = FormulaHelper.yeast(
                widget.receipt!.og,
                widget.receipt!.volume,
                form: value.form!,
                cells: value.cells!,
                rate: value.pitchingRate(widget.receipt!.og));
            }
            if (widget.data != null) {
              widget.data![dataRowIndex].amount = amount;
            }
          }
          widget.onChanged?.call(widget.data ?? [ value ]);
        }
    );
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
              if(_selected.isNotEmpty) TextButton(
                child: Icon(Icons.delete_outline),
                style: TextButton.styleFrom(
                  backgroundColor: FillColor,
                  shape: CircleBorder(),
                ),
                onPressed: () {

                },
              )
            ],
          ),
          Flexible(
            child: SfDataGridTheme(
              data: SfDataGridThemeData(),
              child: FutureBuilder<List<YeastModel>>(
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
                      onEdit: (DataGridRow row, int rowIndex) {
                        _edit(rowIndex);
                      },
                      onRemove: (DataGridRow row, int rowIndex) {
                        // setState(() {
                        //   _data!.then((value) => value.removeAt(rowIndex));
                        // });
                        widget.data!.removeAt(rowIndex);
                        widget.onChanged?.call(widget.data!);
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
                      columns: YeastDataSource.columns(context: context, showQuantity: widget.data != null),
                      // tableSummaryRows: YeastDataSource.summaries(context: context, showQuantity: widget.data != null),
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
    for(YeastModel model in _selected) {
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
      _data = widget.data != null ? Future<List<YeastModel>>.value(widget.data) : Database().getYeasts(searchText: _searchQueryController.value.text, ordered: true);
    });
  }

  _add() async {
    if (widget.allowAdding == true) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return YeastsPage(showCheckboxColumn: true);
      })).then((values) {
        if (values != null) {
          if (widget.data != null) {
            for(YeastModel model in values) {
              var amount = FormulaHelper.yeast(
                  widget.receipt!.og,
                  widget.receipt!.volume,
                  form: model.form!,
                  cells: model.cells!,
                  rate: model.pitchingRate(widget.receipt!.og)
              );
              model.amount = amount.truncateToDouble();
              widget.data!.add(model);
            }
            widget.onChanged?.call(widget.data!);
          }
        }
      });
    } else if (widget.allowEditing == true) {
      setState(() {
        _data!.then((value) {
          value.insert(0, YeastModel(isEdited: true));
          return value;
        });
      });
    }
  }

  _edit(int rowIndex) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return YeastsPage(showCheckboxColumn: true, selectionMode: SelectionMode.singleDeselect);
    })).then((values) {
      if (values != null && values!.isNotEmpty) {
        if (widget.data != null && widget.data!.isNotEmpty) {
          values.first.amount = widget.data![rowIndex].amount;
          widget.data![rowIndex] = values.first;
          widget.onChanged?.call(widget.data!);
        }
      }
    });
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


class YeastDataSource extends EditDataSource {
  List<YeastModel> _data = [];
  final void Function(YeastModel value, int dataRowIndex)? onChanged;
  /// Creates the employee data source class with required details.
  YeastDataSource(BuildContext context, {List<YeastModel>? data, bool? showQuantity, bool? showCheckboxColumn, this.onChanged}) : super(context, showQuantity: showQuantity!, showCheckboxColumn: showCheckboxColumn!) {
    if (data != null) buildDataGridRows(data);
  }

  List<YeastModel> get data => _data;
  set data(List<YeastModel> data) => _data = data;

  List<DataGridRow> getDataRows({List<YeastModel>? data}) {
    List<YeastModel>? list = data ?? _data;
    return list.map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'uuid', value: e.uuid),
      if (showQuantity == true) DataGridCell<double>(columnName: 'amount', value: e.amount),
      DataGridCell<dynamic>(columnName: 'name', value: e.name),
      DataGridCell<dynamic>(columnName: 'reference', value: e.reference),
      DataGridCell<dynamic>(columnName: 'laboratory', value: e.laboratory),
      DataGridCell<Fermentation>(columnName: 'type', value: e.type),
      DataGridCell<Yeast>(columnName: 'form', value: e.form),
      DataGridCell<double>(columnName: 'attenuation', value: e.attenuation),
      DataGridCell<double>(columnName: 'temperature', value: e.temperature),
      DataGridCell<double>(columnName: 'cells', value: e.cells)
    ])).toList();
  }

  void buildDataGridRows(List<YeastModel> data) {
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
    List<YeastModel>? list = data.skip(dataGridRows.length).toList().take(count).toList();
    dataGridRows.addAll(getDataRows(data: list));
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
  bool isNumericType(String columnName) {
    return YeastModel().isNumericType(columnName);
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
            var form = row.getCells().firstWhere((DataGridCell dataGridCell) => dataGridCell.columnName == 'form').value;
            if (form == Yeast.liquid) {
              value = AppLocalizations.of(context)!.volumeFormat(e.value);
            } else {
              value = AppLocalizations.of(context)!.weightFormat(e.value);
            }
          } else if (e.columnName == 'attenuation') {
            value = AppLocalizations.of(context)!.percentFormat(e.value);
          } else if (e.columnName == 'duration') {
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
              alignment: Alignment.center,
              margin: EdgeInsets.all(4),
              child: Icon(Icons.warning_amber_outlined, size: 18, color: Colors.redAccent.withOpacity(0.3))
            );
          }
        }
        return Container(
          alignment: alignment,
          padding: EdgeInsets.all(8.0),
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
            child: Text('Att.', style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
        )
      ),
      GridColumn(
        width: 90,
        columnName: 'temperature',
        allowEditing: false,
        label: Container(
            padding: EdgeInsets.all(8.0),
            alignment: Alignment.centerRight,
            child: Text('Temp.', style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
        )
      ),
      GridColumn(
        width: 90,
        columnName: 'cells',
        allowEditing: false,
        label: Container(
            padding: EdgeInsets.all(8.0),
            alignment: Alignment.centerRight,
            child: Text('\u023B', style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
        )
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

