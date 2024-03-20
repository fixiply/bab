import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/forms/form_hop_page.dart';
import 'package:bab/controller/tables/edit_sfdatagrid.dart';
import 'package:bab/controller/tables/hops_data_table.dart';
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/helpers/import_helper.dart';
import 'package:bab/models/hop_model.dart';
import 'package:bab/models/recipe_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/utils/localized_text.dart';
import 'package:bab/widgets/animated_action_button.dart';
import 'package:bab/widgets/containers/empty_container.dart';
import 'package:bab/widgets/containers/error_container.dart';
import 'package:bab/widgets/custom_dismissible.dart';
import 'package:bab/widgets/custom_state.dart';
import 'package:bab/widgets/dialogs/delete_dialog.dart';
import 'package:bab/widgets/search_text.dart';

// External package
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class HopsPage extends StatefulWidget {
  bool allowEditing;
  bool showCheckboxColumn;
  bool showQuantity;
  bool loadMore;
  RecipeModel? recipe;
  SelectionMode selectionMode;
  HopsPage({Key? key, this.allowEditing = false, this.showCheckboxColumn = false, this.showQuantity = false, this.loadMore = false, this.recipe, this.selectionMode = SelectionMode.multiple}) : super(key: key);

  @override
  HopsPageState createState() => HopsPageState();
}

class HopsPageState extends CustomState<HopsPage> with AutomaticKeepAliveClientMixin<HopsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late HopDataSource _dataSource;
  final DataGridController _dataGridController = DataGridController();
  final TextEditingController _searchQueryController = TextEditingController();
  ScrollController? _controller;
  Future<List<HopModel>>? _data;
  List<HopModel> _selected = [];
  bool _showList = false;
  bool _myData = false;

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
      showAction: false,
      onChanged: (HopModel value, int dataRowIndex) {
        Database().update(value, updateLogs: !currentUser!.isAdmin()).then((value) async {
          showSnackbar(AppLocalizations.of(context)!.text('saved_item'));
        }).onError((e, s) {
          showSnackbar(e.toString(), success: false);
        });
      }
    );
    _dataSource.sortedColumns.add(const SortColumnDetails(name: 'name', sortDirection: DataGridSortDirection.ascending));
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: SearchText(
          _searchQueryController,
          () {  fetch(); }
        ),
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: widget.showCheckboxColumn == true,
        leading: widget.showCheckboxColumn == true ? Row(
          children: [
            Flexible(
              child: IconButton(
                  icon: const Icon(Icons.check),
                  tooltip: AppLocalizations.of(context)!.text('validate'),
                  onPressed: selected.isNotEmpty ? () async {
                    Navigator.pop(context, selected);
                  } : null
              ),
            ),
            Flexible(
                child: IconButton(
                    icon: DeviceHelper.isLargeScreen(context) ? const Icon(Icons.close) : const BackButtonIcon(),
                    tooltip: DeviceHelper.isLargeScreen(context) ? MaterialLocalizations.of(context).closeButtonLabel : MaterialLocalizations.of(context).cancelButtonLabel,
                    onPressed:() async {
                      Navigator.pop(context, []);
                    }
                )
            )
          ]
        ) : null,
        actions: [
          if (_showList && widget.allowEditing) IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.delete_outline),
              tooltip: AppLocalizations.of(context)!.text('delete'),
              onPressed: () {
                _deleteAll();
              }
          ),
          if (currentUser != null && currentUser!.isAdmin() && widget.allowEditing) IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.download_outlined),
            tooltip: AppLocalizations.of(context)!.text('import'),
            onPressed: () {
              ImportHelper.hops(context, () {
                fetch();
              });
            }
          ),
          IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(_myData ? Icons.verified_user_outlined : Icons.shield_outlined),
            tooltip: AppLocalizations.of(context)!.text(_myData ? 'all_data' : 'my_data'),
            onPressed: () {
              setState(() { _myData = !_myData; });
              fetch();
            },
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
      body: RefreshIndicator(
        onRefresh: () => fetch(),
        child: FutureBuilder<List<HopModel>>(
          future: _data,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
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
                  showCheckboxColumn: widget.showCheckboxColumn || _myData,
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
                  columns: HopDataSource.columns(context: context),
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
            return const Center(child: CircularProgressIndicator(strokeWidth: 2.0, valueColor:AlwaysStoppedAnimation<Color>(Colors.black38)));
          }
        )
      ),
      floatingActionButton: Visibility(
        visible: currentUser != null,
        child: AnimatedActionButton(
          title: AppLocalizations.of(context)!.text('new_hop'),
          icon: const Icon(Icons.add),
          onPressed: _new,
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
    switch(widget.selectionMode) {
      case SelectionMode.multiple :
        _dataGridController.selectedRows = rows;
        break;
      case SelectionMode.single :
      case SelectionMode.singleDeselect :
        _dataGridController.selectedRow = rows.isNotEmpty ? rows.first : null;
        break;
      case SelectionMode.none:
        // TODO: Handle this case.
    }
    return _dataGridController;
  }

  Widget _item(HopModel model) {
    if (model.isEditable() && !DeviceHelper.isDesktop) {
      return CustomDismissible(
        context,
        key: Key(model.uuid!),
        child: _card(model),
        onStart: () {
          _edit(model);
        },
        onEnd: () async {
          await _delete(model);
        }
      );
    }
    return _card(model);
  }

  Widget _card(HopModel model) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        title: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              TextSpan(text: AppLocalizations.of(context)!.localizedText(model.name), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              if (model.origin != null) TextSpan(text: '  ${LocalizedText.emoji(model.origin!)}',
                  style: const TextStyle(fontSize: 16, fontFamily: 'Emoji' )
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
                  TextSpan(text: AppLocalizations.of(context)!.text(model.type.toString().toLowerCase()), style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (model.alpha != null || model.beta != null) const TextSpan(text: '  -  '),
                  if (model.alpha != null) TextSpan(text: '${AppLocalizations.of(context)!.text('alpha')}: ${AppLocalizations.of(context)!.percentFormat(model.alpha)}'),
                  if (model.alpha != null && model.beta != null) const TextSpan(text: '   '),
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
        trailing: model.isEditable() && DeviceHelper.isDesktop ? PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          tooltip: AppLocalizations.of(context)!.text('options'),
          onSelected: (value) {
            if (value == 'edit') {
              _edit(model);
            } else if (value == 'remove') {
              _delete(model);
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

  fetch() async {
    setState(() {
      _data = Database().getHops(user: currentUser?.uuid, searchText: _searchQueryController.value.text, ordered: true, myData: _myData);
    });
  }

  _new() {
    HopModel newModel = HopModel();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormHopPage(newModel);
    })).then((value) { fetch(); });
  }

  _edit(HopModel model) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormHopPage(model);
    })).then((value) { fetch(); });
  }

  _delete(HopModel model) async {
    if (await DeleteDialog.model(context, model, forced: true)) {
      fetch();
    }
  }

  Future<bool> _deleteAll() async {
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
        EasyLoading.show(status: AppLocalizations.of(context)!.text('work_in_progress'));
        for (HopModel model in _selected) {
          await Database().delete(model, forced: true);
        }
        setState(() {
          _selected.clear();
        });
      } catch (e) {
        showSnackbar(e.toString(), success: false);
      } finally {
        EasyLoading.dismiss();
      }
      fetch();
      return true;
    }
    return false;
  }
}

