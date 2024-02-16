import 'package:bab/controller/forms/form_equipment_page.dart';
import 'package:bab/helpers/device_helper.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/tanks_page.dart';
import 'package:bab/controller/tables/edit_data_source.dart';
import 'package:bab/controller/tables/edit_sfdatagrid.dart';
import 'package:bab/models/equipment_model.dart';
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
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';


class EquipmentDataTable extends StatefulWidget {
  Widget? title;
  bool allowEditing;
  bool allowSorting;
  bool allowAdding;
  bool sort;
  bool loadMore;
  Color? color;
  bool? showCheckboxColumn;
  bool? showAction;
  SelectionMode? selectionMode;
  Equipment? equipment;
  EquipmentDataTable({Key? key,
    this.title,
    this.allowEditing = true,
    this.allowSorting = true,
    this.allowAdding = false,
    this.sort = true,
    this.loadMore = false,
    this.color,
    this.showCheckboxColumn = true,
    this.showAction = false,
    this.selectionMode = SelectionMode.multiple,
    required this.equipment}) : super(key: key);

  @override
  _EquipmentDataTableState createState() => _EquipmentDataTableState();
}

class _EquipmentDataTableState extends State<EquipmentDataTable> with AutomaticKeepAliveClientMixin {
  late TankDataSource _dataSource;
  final DataGridController _dataGridController = DataGridController();
  final TextEditingController _searchQueryController = TextEditingController();
  double dataRowHeight = 30;
  List<EquipmentModel> _selected = [];
  Future<List<EquipmentModel>>? _data;

  List<EquipmentModel> get selected => _selected;

  @override
  bool get wantKeepAlive => true;

  @override
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
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(child: widget.title ?? SearchText(
                _searchQueryController,
                () {  _fetch(); }
              )),
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
                      onRemove: (int rowIndex) {
                        _remove(rowIndex);
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
                      columns: TankDataSource.columns(context: context, showAction: widget.showAction!),
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
          // widget.onChanged?.call(values);
        }
      });
    } else  {
      EquipmentModel newModel = EquipmentModel(type: Equipment.tank);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return FormEquipmentPage(newModel, widget.equipment);
      })).then((value) { _fetch(); });
    }
  }

  _remove(int rowIndex) async {
    setState(() {
      _data!.then((value) => value.removeAt(rowIndex));
    });
  }
}

class TankDataSource extends EditDataSource {
  List<EquipmentModel> _data = [];
  final void Function(EquipmentModel value, int dataRowIndex)? onChanged;
  final void Function(int rowIndex)? onRemove;
  final void Function(int rowIndex)? onEdit;
  /// Creates the employee data source class with required details.
  TankDataSource(BuildContext context, {List<EquipmentModel>? data, bool? showQuantity, bool? showCheckboxColumn,  bool? showAction, this.onChanged, this.onRemove, this.onEdit}) : super(context, showQuantity: showQuantity, showAction: showAction, showCheckboxColumn: showCheckboxColumn) {
    if (data != null) buildDataGridRows(data);
  }

  List<EquipmentModel> get data => _data;
  set data(List<EquipmentModel> data) => _data = data;

  List<DataGridRow> getDataRows({List<EquipmentModel>? data}) {
    int index = 0;
    List<EquipmentModel>? list = data ?? _data;
    return list.map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'uuid', value: e.uuid),
      DataGridCell<String>(columnName: 'name', value: e.name),
      DataGridCell<double>(columnName: 'volume', value: e.volume),
      DataGridCell<double>(columnName: 'size', value: e.mash_volume),
      DataGridCell<double>(columnName: 'efficiency', value: e.efficiency),
      DataGridCell<double>(columnName: 'absorption', value: e.absorption),
      DataGridCell<double>(columnName: 'lost_volume', value: e.lost_volume),
      if (DeviceHelper.isDesktop && showAction == true) DataGridCell<int>(columnName: 'actions', value: index++),
    ])).toList();
  }

  void buildDataGridRows(List<EquipmentModel> data) {
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
    List<EquipmentModel>? list = data.skip(dataGridRows.length).toList().take(count).toList();
    dataGridRows.addAll(getDataRows(data: list));
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
            if (e.columnName == 'efficiency') {
              value = AppLocalizations.of(context)!.percentFormat(e.value);
            } else value = NumberFormat("#0.#", AppLocalizations.of(context)!.locale.toString()).format(e.value);
            alignment = Alignment.centerRight;
          } else if (e.value is Enum) {
            alignment = Alignment.center;
            value = AppLocalizations.of(context)!.text(value.toString().toLowerCase());
          } else if (e.value is DateTime) {
            alignment = Alignment.centerRight;
            value = AppLocalizations.of(context)!.datetimeFormat(e.value);
          }
          if (e.columnName == 'color') {
            return Container(
                margin: const EdgeInsets.all(4),
                color: ColorHelper.color(e.value),
                child: Center(child: Text(value ?? '', style: const TextStyle(color: Colors.white, fontSize: 14)))
            );
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
  Future<void> onCellSubmit(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex, GridColumn column) async {
    final dynamic oldValue = dataGridRow.getCells().firstWhere((DataGridCell dataGridCell) =>
    dataGridCell.columnName == column.columnName).value ?? '';
    final int dataRowIndex = dataGridRows.indexOf(dataGridRow);
    if (dataRowIndex == -1 || oldValue == newCellValue) {
      return;
    }
    int columnIndex = showCheckboxColumn == true ? rowColumnIndex.columnIndex-1 : rowColumnIndex.columnIndex;
    switch(column.columnName) {
      case 'name':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<String>(columnName: column.columnName, value: newCellValue);
        _data[dataRowIndex].name = newCellValue;
        break;
      case 'volume':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<double>(columnName: column.columnName, value: newCellValue);
        _data[dataRowIndex].volume = newCellValue;
        break;
      case 'size':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<double>(columnName: column.columnName, value: newCellValue);
        _data[dataRowIndex].mash_volume = newCellValue;
        break;
      case 'efficiency':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<double>(columnName: column.columnName, value: newCellValue);
        _data[dataRowIndex].efficiency = newCellValue;
        break;
      case 'absorption':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<double>(columnName: column.columnName, value: newCellValue);
        _data[dataRowIndex].absorption = newCellValue;
        break;
      case 'lost_volume':
        dataGridRows[dataRowIndex].getCells()[columnIndex] =
            DataGridCell<double>(columnName: column.columnName, value: newCellValue);
        _data[dataRowIndex].lost_volume = newCellValue;
        break;
    }
    onChanged?.call(_data[dataRowIndex], dataRowIndex);
    updateDataSource();
  }

  @override
  void updateDataSource() {
    notifyListeners();
  }

  static List<GridColumn> columns({required BuildContext context, bool showAction = false}) {
    return <GridColumn>[
      GridColumn(
          columnName: 'uuid',
          visible: false,
          label: Container()
      ),
      GridColumn(
          columnName: 'name',
          label: Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.centerLeft,
              child: Text(AppLocalizations.of(context)!.text('name'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
          )
      ),
      GridColumn(
          width: 90,
          columnName: 'volume',
          label: Tooltip(
              message: AppLocalizations.of(context)!.text('boil_volume'),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.centerRight,
                child: Text(AppLocalizations.of(context)!.text('boiling'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
            )
          )
      ),
      GridColumn(
          width: 90,
          columnName: 'size',
          label: Tooltip(
              message: AppLocalizations.of(context)!.text('mash_volume'),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.centerRight,
                child: Text(AppLocalizations.of(context)!.text('brew'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
            )
          )
      ),
      GridColumn(
          width: 90,
          columnName: 'efficiency',
          label: Tooltip(
              message: AppLocalizations.of(context)!.text('mash_efficiency'),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.centerRight,
                child: Text(AppLocalizations.of(context)!.text('efficiency'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
            )
          )
      ),
      GridColumn(
          width: 90,
          columnName: 'absorption',
          label: Tooltip(
              message: AppLocalizations.of(context)!.text('absorption_grains'),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.centerRight,
                child: Text(AppLocalizations.of(context)!.text('absorption'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
            )
          )
      ),
      GridColumn(
          width: 90,
          columnName: 'lost_volume',
          label: Tooltip(
            message: AppLocalizations.of(context)!.text('lost_volume'),
            child: Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.centerRight,
                child: Text(AppLocalizations.of(context)!.text('lost'), style: TextStyle(color: Theme.of(context).primaryColor), overflow: TextOverflow.ellipsis)
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
}

