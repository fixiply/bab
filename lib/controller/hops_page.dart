import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bb/controller/forms/form_hop_page.dart';
import 'package:bb/controller/tables/edit_sfdatagrid.dart';
import 'package:bb/controller/tables/hops_data_table.dart';
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/helpers/import_helper.dart';
import 'package:bb/models/hop_model.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/utils/localized_text.dart';
import 'package:bb/widgets/containers/empty_container.dart';
import 'package:bb/widgets/containers/error_container.dart';
import 'package:bb/widgets/dialogs/delete_dialog.dart';
import 'package:bb/widgets/search_text.dart';

// External package
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class HopsPage extends StatefulWidget {
  bool allowEditing;
  bool showCheckboxColumn;
  bool showQuantity;
  bool loadMore;
  ReceiptModel? receipt;
  SelectionMode selectionMode;
  HopsPage({Key? key, this.allowEditing = false, this.showCheckboxColumn = false, this.showQuantity = false, this.loadMore = false, this.receipt, this.selectionMode : SelectionMode.multiple}) : super(key: key);

  _HopsPageState createState() => new _HopsPageState();
}

class _HopsPageState extends State<HopsPage> with AutomaticKeepAliveClientMixin<HopsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late HopDataSource _dataSource;
  final DataGridController _dataGridController = DataGridController();
  final TextEditingController _searchQueryController = TextEditingController();
  ScrollController? _controller;
  Future<List<HopModel>>? _data;
  List<HopModel> _selected = [];
  bool _showList = false;

  List<HopModel> get selected => _selected;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _dataSource = HopDataSource(context,
      showQuantity: widget.showQuantity,
      showCheckboxColumn: widget.showCheckboxColumn,
      onChanged: (HopModel value, int dataRowIndex) {
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
              ImportHelper.hops(context, () {
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
          child: FutureBuilder<List<HopModel>>(
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
                    selectionMode: widget.selectionMode,
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
                    columns: HopDataSource.columns(context: context, showQuantity: false),
                  );
                }
                return ListView.builder(
                  controller: _controller,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: snapshot.hasData ? snapshot.data!.length : 0,
                  itemBuilder: (context, index) {
                    HopModel model = snapshot.data![index];
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
          visible: currentUser != null,
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
    for(HopModel model in _selected) {
      int index = _dataSource.data.indexOf(model);
      if (index != -1) {
        rows.add(_dataSource.dataGridRows[index]);
      }
    }
    _dataGridController.selectedRows = rows;
    return _dataGridController;
  }

  Widget _item(HopModel model) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        title: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              TextSpan(text: AppLocalizations.of(context)!.localizedText(model.name), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              if (model.origin != null) TextSpan(text: '  ${LocalizedText.emoji(model.origin!)}',
                  style: TextStyle(fontSize: 16, fontFamily: 'Emoji' )
              ),
            ],
          ),
        ),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  TextSpan(text: AppLocalizations.of(context)!.text(model.type.toString().toLowerCase()), style: TextStyle(fontWeight: FontWeight.bold)),
                  if (model.alpha != null || model.beta != null) TextSpan(text: '  -  '),
                  if (model.alpha != null) TextSpan(text: '${AppLocalizations.of(context)!.text('alpha')}: ${AppLocalizations.of(context)!.percentFormat(model.alpha)}'),
                  if (model.alpha != null && model.beta != null) TextSpan(text: '   '),
                  if (model.beta != null) TextSpan(text: '${AppLocalizations.of(context)!.text('beta')}: ${AppLocalizations.of(context)!.percentFormat(model.beta)}'),
                ],
              ),
            ),
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
      _data = Database().getHops(searchText: _searchQueryController.value.text, ordered: true);
    });
  }

  _new() {
    HopModel newModel = HopModel();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormHopPage(newModel);
    })).then((value) { _fetch(); });
  }

  _edit(HopModel model) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormHopPage(model);
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
        for (HopModel model in _selected) {
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

