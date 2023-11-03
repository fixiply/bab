import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/forms/form_equipment_page.dart';
import 'package:bab/controller/tables/edit_sfdatagrid.dart';
import 'package:bab/controller/tables/tanks_data_table.dart';
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/models/equipment_model.dart';
import 'package:bab/models/receipt_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/widgets/animated_action_button.dart';
import 'package:bab/widgets/containers/empty_container.dart';
import 'package:bab/widgets/containers/error_container.dart';
import 'package:bab/widgets/custom_image.dart';
import 'package:bab/widgets/dialogs/delete_dialog.dart';
import 'package:bab/widgets/search_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// External package
import 'package:expandable_text/expandable_text.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class FermentersPage extends StatefulWidget {
  bool allowEditing;
  bool showCheckboxColumn;
  bool loadMore;
  ReceiptModel? receipt;
  FermentersPage({Key? key, this.allowEditing = false, this.showCheckboxColumn = false, this.loadMore = false, this.receipt}) : super(key: key);

  @override
  _FermentersPageState createState() => _FermentersPageState();
}

class CustomListItem extends StatelessWidget {
  const CustomListItem({
    required this.leading,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.weight,
  });

  final Widget leading;
  final Widget title;
  final Widget subtitle;
  final Widget? trailing;
  final double? weight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: weight,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          leading,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                title,
                Flexible(
                  child: subtitle,
                ),
              ]
            )
          ),
          trailing ?? Container()
        ],
      ),
    );
  }
}

class _FermentersPageState extends State<FermentersPage> with AutomaticKeepAliveClientMixin<FermentersPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late TankDataSource _dataSource;
  final DataGridController _dataGridController = DataGridController();
  final TextEditingController _searchQueryController = TextEditingController();
  ScrollController? _controller;
  Future<List<EquipmentModel>>? _data;
  final List<EquipmentModel> _selected = [];
  bool _showList = false;

  List<EquipmentModel> get selected => _selected;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _dataSource = TankDataSource(context,
      showCheckboxColumn: widget.showCheckboxColumn,
      onChanged: (EquipmentModel value, int dataRowIndex) {
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
          icon: DeviceHelper.isLargeScreen(context) ? const Icon(Icons.close) : const BackButtonIcon(),
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
                _deleteAll();
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
      body: RefreshIndicator(
        onRefresh: () => _fetch(),
        child: FutureBuilder<List<EquipmentModel>>(
          future: _data,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return EmptyContainer(message: AppLocalizations.of(context)!.text('no_fermenter'), initHeight: 46);
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
                  columns: TankDataSource.columns(context: context, showQuantity: false),
                );
              }
              return ListView.builder(
                controller: _controller,
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: snapshot.hasData ? snapshot.data!.length : 0,
                itemBuilder: (context, index) {
                  EquipmentModel model = snapshot.data![index];
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
          title: AppLocalizations.of(context)!.text('add'),
          icon: const Icon(Icons.add),
          onPressed: _new,
        )
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

  Widget _item(EquipmentModel model) {
    if (model.isEditable() && !DeviceHelper.isDesktop) {
      return Dismissible(
          key: Key(model.uuid!),
          child: _card(model),
          background: Container(
              color: Colors.red,
              padding: EdgeInsets.only(left: 15),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const Icon(Icons.delete, color: Colors.white)
                      ]
                  )
              )
          ),
          secondaryBackground: Container(
              color: Colors.blue,
              padding: EdgeInsets.only(right: 15),
              child: Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        const Icon(Icons.edit, color: Colors.white)
                      ]
                  )
              )
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              return await _delete(model);
            }
            if (direction == DismissDirection.endToStart) {
              _edit(model);
              return false;
            }
            return false;
          }
      );
    }
    return _card(model);
  }

  Widget _card(EquipmentModel model) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: CustomListItem(
        weight: 100,
        leading: CustomImage.network(model.image!.url, height: 100, width: 70, emptyImage: Image.asset('assets/images/logo.jpg', fit: BoxFit.fill)),
        title: Text(AppLocalizations.of(context)!.localizedText(model.name), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  if (model.volume != null) TextSpan(text: '${AppLocalizations.of(context)!.text('tank_volume')}: ${AppLocalizations.of(context)!.litterVolumeFormat(model.volume)}'),
                  if (model.volume != null || model.mash_volume != null) const TextSpan(text: '  -  '),
                  if (model.mash_volume != null) TextSpan(text: '${AppLocalizations.of(context)!.text('mash_volume')}: ${AppLocalizations.of(context)!.litterVolumeFormat(model.mash_volume)}'),
                ],
              ),
            ),
            if (model.efficiency != null ) Text('${AppLocalizations.of(context)!.text('mash_efficiency')}: ${AppLocalizations.of(context)!.percentFormat(model.efficiency)}'),
            if (model.notes != null ) _text(AppLocalizations.of(context)!.localizedText(model.notes))
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

  Widget _text(String text) {
    return DeviceHelper.isDesktop ? MarkdownBody(
        data: text,
        fitContent: true,
        shrinkWrap: true,
        softLineBreak: true,
        styleSheet: MarkdownStyleSheet(
            textAlign: WrapAlignment.start
        )
    ) :
    ExpandableText(
      text,
      linkColor: Theme.of(context).primaryColor,
      expandText: AppLocalizations.of(context)!.text('show_more').toLowerCase(),
      collapseText: AppLocalizations.of(context)!.text('show_less').toLowerCase(),
      maxLines: 3,
    );
  }

  _fetch() async {
    setState(() {
      _data = Database().getEquipments(type: Equipment.fermenter, searchText: _searchQueryController.value.text, ordered: true);
    });
  }

  _new() {
    EquipmentModel newModel = EquipmentModel(type: Equipment.tank);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormEquipmentPage(newModel, Equipment.tank);
    })).then((value) { _fetch(); });
  }

  _edit(EquipmentModel model) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormEquipmentPage(model, Equipment.tank);
    })).then((value) { _fetch(); });
  }

  _delete(EquipmentModel model) async {
    if (await DeleteDialog.model(context, model, forced: true)) {
      _fetch();
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
        EasyLoading.show(status: AppLocalizations.of(context)!.text('in_progress'));
        for (EquipmentModel model in _selected) {
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
            duration: const Duration(seconds: 10)
        )
    );
  }
}

