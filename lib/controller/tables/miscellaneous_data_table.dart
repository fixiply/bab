import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/miscellaneous_page.dart';
import 'package:bb/controller/tables/edit_sfdatagrid.dart';
import 'package:bb/models/miscellaneous_model.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/utils/quantity.dart';
import 'package:bb/widgets/containers/error_container.dart';
import 'package:bb/widgets/image_animate_rotate.dart';
import 'package:bb/widgets/search_text.dart';

// External package
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class MiscellaneousDataTable extends StatefulWidget {
  List<Quantity>? data;
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
  final void Function(List<Quantity> value)? onChanged;
  MiscellaneousDataTable({Key? key,
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
  MiscellaneousDataTableState createState() => new MiscellaneousDataTableState();
}

class MiscellaneousDataTableState extends State<MiscellaneousDataTable> with AutomaticKeepAliveClientMixin {
  late MiscellaneousDataSource _dataSource;
  final DataGridController _dataGridController = DataGridController();
  final TextEditingController _searchQueryController = TextEditingController();
  double dataRowHeight = 30;
  List<MiscellaneousModel> _selected = [];
  Future<List<MiscellaneousModel>>? _data;

  List<MiscellaneousModel> get selected => _selected;

  @override
  bool get wantKeepAlive => true;

  void initState() {
    super.initState();
    _dataSource = MiscellaneousDataSource(context,
        showQuantity: widget.data != null,
        showCheckboxColumn: widget.showCheckboxColumn!,
        onChanged: (MiscellaneousModel value, int dataRowIndex) {
          if (widget.data != null) {
            widget.data![dataRowIndex].amount = value.amount;
            widget.data![dataRowIndex].use = value.use?.index;
            widget.data![dataRowIndex].duration = value.time;
          }
          widget.onChanged?.call(widget.data ?? [Quantity(uuid: value.uuid, amount: value.amount, use: value.use!.index, duration: value.time)]);
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
              child: FutureBuilder<List<MiscellaneousModel>>(
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
                      controller: _dataGridController,
                      onRemove: (DataGridRow row, int rowIndex) {
                        setState(() {
                          _data!.then((value) => value.removeAt(rowIndex));
                        });
                        widget.data!.removeAt(rowIndex);
                        widget.onChanged?.call(widget.data!);
                      },
                      onSelectionChanged: (List<DataGridRow> addedRows, List<DataGridRow> removedRows) {
                        if (widget.showCheckboxColumn == true) {
                          for (var row in addedRows) {
                            final index = _dataSource.rows.indexOf(row);
                            _selected.add(snapshot.data![index]);
                          }
                          for (var row in removedRows) {
                            final index = _dataSource.rows.indexOf(row);
                            _selected.remove(snapshot.data![index]);
                          }
                        }
                      },
                      columns: MiscellaneousModel.columns(context: context, showQuantity: widget.data != null),
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

  _fetch() async {
    setState(() {
      _data = Database().getMiscellaneous(quantities: widget.data, searchText: _searchQueryController.value.text, ordered: true);
    });
  }

  _add() async {
    if (widget.allowAdding == true) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return MiscellaneousPage(showCheckboxColumn: true);
      })).then((values) {
        if (values != null) {
          setState(() {
            _data!.then((value) => value.addAll(values));
          });
          if (widget.data != null) {
            for(MiscellaneousModel model in values) {
              widget.data!.add(Quantity(uuid: model.uuid));
            }
            widget.onChanged?.call(widget.data!);
          }
        }
      });
    } else if (widget.allowEditing == true) {
      setState(() {
        _data!.then((value) {
          value.insert(0, MiscellaneousModel(isEdited: true));
          return value;
        });
      });
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
