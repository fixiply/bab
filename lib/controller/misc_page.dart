import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/forms/form_misc_page.dart';
import 'package:bb/controller/tables/edit_sfdatagrid.dart';
import 'package:bb/controller/tables/misc_data_table.dart';
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/helpers/import_helper.dart';
import 'package:bb/models/misc_model.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/widgets/containers/empty_container.dart';
import 'package:bb/widgets/containers/error_container.dart';
import 'package:bb/widgets/dialogs/delete_dialog.dart';
import 'package:bb/widgets/search_text.dart';

// External package
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class MiscPage extends StatefulWidget {
  bool allowEditing;
  bool showCheckboxColumn;
  bool showQuantity;
  bool loadMore;
  ReceiptModel? receipt;
  MiscPage({Key? key, this.allowEditing = false, this.showCheckboxColumn = false, this.showQuantity = false, this.loadMore = false, this.receipt}) : super(key: key);

  _MiscPageState createState() => new _MiscPageState();
}

class _MiscPageState extends State<MiscPage> with AutomaticKeepAliveClientMixin<MiscPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late MiscDataSource _dataSource;
  final DataGridController _dataGridController = DataGridController();
  final TextEditingController _searchQueryController = TextEditingController();
  ScrollController? _controller;
  Future<List<MiscModel>>? _data;
  List<MiscModel> _selected = [];
  bool _showList = false;

  List<MiscModel> get selected => _selected;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _dataSource = MiscDataSource(context,
      showQuantity: widget.showQuantity,
      showCheckboxColumn: widget.showCheckboxColumn,
      onChanged: (MiscModel value, int dataRowIndex) {
        Database().update(value).then((value) async {
          _showSnackbar(AppLocalizations.of(context)!.text('saved_item'));
        }).onError((e, s) {
          _showSnackbar(e.toString());
        });
      }
    );
    _dataSource.sortedColumns.add(const SortColumnDetails(name: 'name', sortDirection: DataGridSortDirection.ascending));
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: SearchText(
          _searchQueryController,
          () {  _fetch(); }
        ),
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: widget.showCheckboxColumn == true,
        leading: widget.showCheckboxColumn == true ? IconButton(
            icon: DeviceHelper.isDesktop ? Icon(Icons.close) : const BackButtonIcon(),
          onPressed:() async {
            Navigator.pop(context, selected);
          }
        ) : null,
        actions: [
          if (_showList && widget.allowEditing) IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.delete_outline),
              tooltip: AppLocalizations.of(context)!.text('delete'),
              onPressed: () {
                _delete();
              }
          ),
          if (widget.allowEditing) IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.download_outlined),
            tooltip: AppLocalizations.of(context)!.text('import'),
            onPressed: () {
              ImportHelper.miscellaneous(context, () {
                _fetch();
              });
            }
          ),
          IconButton(
            padding: EdgeInsets.zero,
            icon: _showList ? const Icon(Icons.grid_view_outlined) : const Icon(Icons.format_list_bulleted_outlined),
            tooltip: AppLocalizations.of(context)!.text(_showList ? 'grid_view' : 'view_list'),
            onPressed: () {
              setState(() { _showList = !_showList; });
            },
          ),
        ],
      ),
      body: Container(
        child: RefreshIndicator(
          onRefresh: () => _fetch(),
          child: FutureBuilder<List<MiscModel>>(
            future: _data,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.length == 0) {
                  return EmptyContainer(message: AppLocalizations.of(context)!.text('no_result'));
                }
                if (_showList || widget.showCheckboxColumn == true) {
                  if (widget.loadMore) {
                    _dataSource.data = snapshot.data!;
                    _dataSource.handleLoadMoreRows();
                  } else {
                    _dataSource.buildDataGridRows(snapshot.data!);
                  }
                  _dataSource.notifyListeners();
                  return EditSfDataGrid(
                    context,
                    allowEditing: widget.allowEditing,
                    showCheckboxColumn: widget.allowEditing || widget.showCheckboxColumn,
                    selectionMode: SelectionMode.multiple,
                    source: _dataSource,
                    controller: getDataGridController(),
                    onSelectionChanged: (List<DataGridRow> addedRows, List<DataGridRow> removedRows) {
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
                    },
                    columns: MiscDataSource.columns(context: context, showQuantity: false),
                  );
                }
                return ListView.builder(
                  controller: _controller,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: snapshot.hasData ? snapshot.data!.length : 0,
                  itemBuilder: (context, index) {
                    MiscModel model = snapshot.data![index];
                    return _item(model);
                  }
                );
              }
              if (snapshot.hasError) {
                return ErrorContainer(snapshot.error.toString());
              }
              return Center(child: CircularProgressIndicator(strokeWidth: 2.0, valueColor:AlwaysStoppedAnimation<Color>(Colors.black38)));
            }
          )
        ),
      ),
      floatingActionButton: Visibility(
        visible: currentUser != null && currentUser!.hasRole(),
        child: FloatingActionButton(
          onPressed: _new,
          backgroundColor: Theme.of(context).primaryColor,
          tooltip: AppLocalizations.of(context)!.text('new'),
          child: const Icon(Icons.add)
        )
      )
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

  Widget _item(MiscModel model) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        title: Text(AppLocalizations.of(context)!.localizedText(model.name),  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (model.type != Misc.other) Text(AppLocalizations.of(context)!.text(model.type.toString().toLowerCase()), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
            if (model.notes != null ) ExpandableText(
              AppLocalizations.of(context)!.localizedText(model.notes),
              linkColor: Theme.of(context).primaryColor,
              expandText: AppLocalizations.of(context)!.text('show_more').toLowerCase(),
              collapseText: AppLocalizations.of(context)!.text('show_less').toLowerCase(),
              maxLines: 3,
            )
          ],
        ),
        trailing: model.isEditable() ? PopupMenuButton<String>(
          icon: Icon(Icons.more_vert),
          tooltip: AppLocalizations.of(context)!.text('options'),
          onSelected: (value) {
            if (value == 'edit') {
              _edit(model);
            } else if (value == 'remove') {
              DeleteDialog.model(context, model, forced: true);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem(
              value: 'edit',
              child: Text(AppLocalizations.of(context)!.text('edit')),
            ),
            PopupMenuItem(
              value: 'remove',
              child: Text(AppLocalizations.of(context)!.text('remove')),
            ),
          ]
        ) : null
      )
    );
  }

  _fetch() async {
    setState(() {
      _data = Database().getMiscellaneous(searchText: _searchQueryController.value.text, ordered: true);
    });
  }

  _new() {
    MiscModel newModel = MiscModel();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormMiscPage(newModel);
    })).then((value) { _fetch(); });
  }

  _edit(MiscModel model) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormMiscPage(model);
    })).then((value) { _fetch(); });
  }

  Future<bool> _delete() async {
    bool confirm = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return DeleteDialog(
            title: AppLocalizations.of(context)!.text('delete_items_title'),
          );
        }
    );
    if (confirm) {
      try {
        EasyLoading.show(status: AppLocalizations.of(context)!.text('in_progress'));
        for (MiscModel model in _selected) {
          await Database().delete(model, forced: true);
        }
        setState(() {
          _selected.clear();
        });
      } catch (e) {
        _showSnackbar(e.toString());
      } finally {
        EasyLoading.dismiss();
      }
      _fetch();
      return true;
    }
    return false;
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
