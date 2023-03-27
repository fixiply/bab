import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/fermentables_page.dart';
import 'package:bb/controller/tables/edit_sfdatagrid.dart';
import 'package:bb/models/fermentable_model.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/utils/quantity.dart';
import 'package:bb/widgets/containers/error_container.dart';
import 'package:bb/widgets/image_animate_rotate.dart';

// External package
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';


class FermentablesDataTable extends StatefulWidget {
  List<Quantity>? data;
  Widget? title;
  bool inventory;
  bool allowEditing;
  bool allowSorting;
  bool allowAdding;
  bool sort;
  Color? color;
  bool? showCheckboxColumn;
  SelectionMode? selectionMode;
  ReceiptModel? receipt;
  final void Function(List<Quantity>? value)? onChanged;
  FermentablesDataTable({Key? key,
    this.data,
    this.title,
    this.inventory = false,
    this.allowEditing = true,
    this.allowSorting = true,
    this.allowAdding = false,
    this.sort = true,
    this.color,
    this.showCheckboxColumn = true,
    this.selectionMode = SelectionMode.multiple,
    this.receipt,
    this.onChanged}) : super(key: key);
  FermentablesDataTableState createState() => new FermentablesDataTableState();
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

  void initState() {
    super.initState();
    _dataSource = FermentableDataSource(context,
      showQuantity: widget.data != null,
      showCheckboxColumn: widget.showCheckboxColumn!,
      onChanged: (FermentableModel value) {
        var quantity = Quantity(uuid: value.uuid, amount: value.amount, use: value.method);
        if (widget.data != null) {
          widget.data!.remove(quantity);
          widget.data!.add(quantity);
        }
        widget.onChanged?.call(widget.data ?? [quantity]);
      }
    );
    _dataSource.sortedColumns.add(const SortColumnDetails(name: 'name', sortDirection: DataGridSortDirection.ascending));
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    final Locale locale = AppLocalizations.of(context)!.locale;
    return Container(
      color: widget.color,
      padding: EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child:  Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(child: widget.title ?? (widget.data == null ? _buildSearchField() : Container())),
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
            )
          ),
          Flexible(
            child: SfDataGridTheme(
              data: SfDataGridThemeData(),
              child: FutureBuilder<List<FermentableModel>>(
                future: _data,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _dataSource.buildDataGridRows(snapshot.data!);
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
                      columns: FermentableModel.columns(context: context, showQuantity: widget.data != null),
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

  Widget _buildSearchField() {
    return Container(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: FillColor
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: TextField(
              controller: _searchQueryController,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.all(14),
                icon: Padding(
                  padding: EdgeInsets.only(left: 4.0),
                  child: Icon(Icons.search, color: Theme.of(context).primaryColor)
                ),
                hintText: AppLocalizations.of(context)!.text('search_hint'),
                hintStyle: TextStyle(color: Theme.of(context).primaryColor),
                border: InputBorder.none
              ),
              style: TextStyle(fontSize: 14.0),
              onChanged: (query) {
                return _fetch();
              },
            )
          ),
          if (_searchQueryController.text.length > 0) IconButton(
              icon: Icon(Icons.clear, color: Theme.of(context).primaryColor),
              onPressed: () {
                _searchQueryController.clear();
                _fetch();
              }
          )
        ],
      )
    );
  }

  _fetch() async {
    setState(() {
      _data = Database().getFermentables(quantities: widget.data, searchText: _searchQueryController.value.text, ordered: true);
    });
  }

  _add() async {
    if (widget.allowAdding == true) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return FermentablesPage(showCheckboxColumn: true);
      })).then((values) {
        if (values != null) {
          setState(() {
            _data!.then((value) => value.addAll(values));
          });
          if (widget.data != null) {
            for(FermentableModel model in values) {
              widget.data!.add(Quantity(uuid: model.uuid));
            }
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

