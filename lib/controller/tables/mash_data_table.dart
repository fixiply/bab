import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/tables/edit_sfdatagrid.dart';
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/models/recipe_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/mash.dart';
import 'package:bab/widgets/duration_picker.dart';

// External package
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class MashDataTable extends StatefulWidget {
  List<Mash>? data;
  Widget? title;
  bool allowEditing;
  bool allowSorting;
  bool sort;
  Color? color;
  bool? showCheckboxColumn;
  bool? showAction;
  SelectionMode? selectionMode;
  RecipeModel? recipe;
  final void Function(List<Mash>? value)? onChanged;
  MashDataTable({Key? key,
    this.data,
    this.title,
    this.allowEditing = true,
    this.allowSorting = false,
    this.sort = false,
    this.color,
    this.showCheckboxColumn = true,
    this.showAction = false,
    this.selectionMode = SelectionMode.multiple,
    this.recipe,
    this.onChanged}) : super(key: key);

  @override
  MashDataTableState createState() => MashDataTableState();
}

class MashDataTableState extends State<MashDataTable> with AutomaticKeepAliveClientMixin {
  late MashDataSource _dataSource;
  final DataGridController _dataGridController = DataGridController();
  double dataRowHeight = 30;
  List<Mash> _selected = [];

  List<Mash> get selected => _selected;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _dataSource = MashDataSource(context,
      data: widget.data ?? [],
      showCheckboxColumn: widget.showCheckboxColumn!,
      showAction: widget.showAction,
      onRemove: (int rowIndex) {
        _remove(rowIndex);
      },
      onChanged: (Mash value, int dataRowIndex) {
        if (widget.data != null) {
          widget.data![dataRowIndex].name = value.name;
          widget.data![dataRowIndex].type = value.type;
          widget.data![dataRowIndex].temperature = value.temperature;
          widget.data![dataRowIndex].duration = value.duration;
        }
        widget.onChanged?.call(widget.data ?? [value]);
      }
    );
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
              Expanded(child: widget.title ?? Container()),
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
              child: EditSfDataGrid(
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
                        _selected.add(widget.data![index]);
                      }
                      for(var row in removedRows) {
                        final index = _dataSource.rows.indexOf(row);
                        _selected.remove(widget.data![index]);
                      }
                    });
                  }
                },
                columns: Mash.columns(context: context, showAction: widget.showAction!),
              ),
            )
          )
        ]
      )
    );
  }

  DataGridController getDataGridController() {
    List<DataGridRow> rows = [];
    for(Mash model in _selected) {
      int index = _dataSource.data.indexOf(model);
      if (index != -1) {
        rows.add(_dataSource.dataGridRows[index]);
      }
    }
    _dataGridController.selectedRows = rows;
    return _dataGridController;
  }

  _add() async {
    setState(() {
      widget.data!.add(Mash(name: AppLocalizations.of(context)!.text(Bearing.mash_in.toString().toLowerCase()), duration: widget.recipe!.boil));
    });
    _dataSource.buildDataGridRows(widget.data!);
    _dataSource.notifyListeners();
    widget.onChanged?.call(widget.data!);
  }

  _remove(int rowIndex) async {
    widget.data!.removeAt(rowIndex);
    _dataSource.buildDataGridRows(widget.data!);
    _dataSource.notifyListeners();
    widget.onChanged?.call(widget.data!);
  }
}

