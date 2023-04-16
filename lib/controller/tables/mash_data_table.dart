import 'package:bb/utils/mash.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/tables/edit_sfdatagrid.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:bb/utils/constants.dart';

// External package
import 'package:flutter/services.dart';
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
  SelectionMode? selectionMode;
  ReceiptModel? receipt;
  final void Function(List<Mash>? value)? onChanged;
  MashDataTable({Key? key,
    this.data,
    this.title,
    this.allowEditing = true,
    this.allowSorting = true,
    this.sort = true,
    this.color,
    this.showCheckboxColumn = true,
    this.selectionMode = SelectionMode.multiple,
    this.receipt,
    this.onChanged}) : super(key: key);
  MashDataTableState createState() => new MashDataTableState();
}

class MashDataTableState extends State<MashDataTable> with AutomaticKeepAliveClientMixin {
  late MashDataSource _dataSource;
  final DataGridController _dataGridController = DataGridController();
  double dataRowHeight = 30;
  List<Mash> _selected = [];

  List<Mash> get selected => _selected;

  @override
  bool get wantKeepAlive => true;

  void initState() {
    super.initState();
    _dataSource = MashDataSource(context,
      data: widget.data ?? [],
      showCheckboxColumn: widget.showCheckboxColumn!,
      onChanged: (Mash value) {
        widget.onChanged?.call([value]);
      }
    );
    if (widget.allowEditing != true) _dataSource.sortedColumns.add(const SortColumnDetails(name: 'name', sortDirection: DataGridSortDirection.ascending));
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
              Expanded(child: widget.title ?? Container()),
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
              child: EditSfDataGrid(
                context,
                showCheckboxColumn: widget.showCheckboxColumn!,
                selectionMode: widget.selectionMode!,
                source: _dataSource,
                allowEditing: widget.allowEditing,
                allowSorting: widget.allowSorting,
                controller: _dataGridController,
                verticalScrollPhysics: const NeverScrollableScrollPhysics(),
                onSelectionChanged: (List<DataGridRow> addedRows, List<DataGridRow> removedRows) {
                  if (widget.showCheckboxColumn == true) {
                    for (var row in addedRows) {
                      final index = _dataSource.rows.indexOf(row);
                      _selected.add(widget.data![index]);
                    }
                    for (var row in removedRows) {
                      final index = _dataSource.rows.indexOf(row);
                      _selected.remove(widget.data![index]);
                    }
                  }
                },
                columns: Mash.columns(context: context, showQuantity: widget.data != null),
              ),
            )
          )
        ]
      )
    );
  }

  _add() async {
    setState(() {
      widget.data!.insert(0, Mash(name: 'Saccharification', duration: widget.receipt!.boil));
    });
    _dataSource.buildDataGridRows(widget.data!);
    _dataSource.notifyListeners();
    widget.onChanged?.call(widget.data!);
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

