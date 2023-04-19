import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bb/controller/brew_page.dart';
import 'package:bb/controller/forms/form_brew_page.dart';
import 'package:bb/controller/tables/brew_data_source.dart';
import 'package:bb/controller/tables/edit_sfdatagrid.dart';
import 'package:bb/helpers/color_helper.dart';
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/helpers/import_helper.dart';
import 'package:bb/models/brew_model.dart';
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
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class BrewsPage extends StatefulWidget {
  bool allowEditing;
  bool loadMore;
  BrewsPage({Key? key, this.allowEditing = false, this.loadMore = false}) : super(key: key);

  _BrewsPageState createState() => new _BrewsPageState();
}

class _BrewsPageState extends State<BrewsPage> with AutomaticKeepAliveClientMixin<BrewsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late BrewDataSource _dataSource;
  final DataGridController _dataGridController = DataGridController();
  final TextEditingController _searchQueryController = TextEditingController();
  ScrollController? _controller;
  Future<List<BrewModel>>? _data;
  List<BrewModel> _selected = [];
  bool _showList = false;

  List<BrewModel> get selected => _selected;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _dataSource = BrewDataSource(context,
        showCheckboxColumn: widget.allowEditing,
        onChanged: (BrewModel value, int dataRowIndex) {
          Database().update(value).then((value) async {
            _showSnackbar(AppLocalizations.of(context)!.text('saved_item'));
          }).onError((e, s) {
            _showSnackbar(e.toString());
          });
        }
    );
    _dataSource.sortedColumns.add(const SortColumnDetails(name: 'number', sortDirection: DataGridSortDirection.ascending));
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: SearchText(_searchQueryController, () {  _fetch(); }),
          elevation: 0,
          foregroundColor: Theme.of(context).primaryColor,
          backgroundColor: Colors.white,
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
                  ImportHelper.fermentables(context, () {
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
            child: FutureBuilder<List<BrewModel>>(
              future: _data,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.length == 0) {
                    return EmptyContainer(message: AppLocalizations.of(context)!.text('no_result'));
                  }
                  if (_showList) {
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
                      showCheckboxColumn: widget.allowEditing,
                      selectionMode: SelectionMode.multiple,
                      source: _dataSource,
                      controller: getDataGridController(),
                      onEdit: (DataGridRow row, int rowIndex) {
                        _data!.then((value) async {
                          BrewModel model = value.elementAt(rowIndex);
                          if (model != null) {
                            _edit(model);
                          }
                        });
                      },
                      onRemove: (DataGridRow row, int rowIndex) {
                        _data!.then((value) async {
                          BrewModel model = value.elementAt(rowIndex);
                          if (model != null) {
                            if (await DeleteDialog.model(
                                context, model, forced: true)) {
                              _fetch();
                            }
                          }
                        });
                      },
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
                      columns: BrewDataSource.columns(
                          context: context, showQuantity: false),
                    );
                  }
                  return ListView.builder(
                      controller: _controller,
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: snapshot.hasData ? snapshot.data!.length : 0,
                      itemBuilder: (context, index) {
                        BrewModel model = snapshot.data![index];
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
    for(BrewModel model in _selected) {
      int index = _dataSource.data.indexOf(model);
      if (index != -1) {
        rows.add(_dataSource.dataGridRows[index]);
      }
    }
    _dataGridController.selectedRows = rows;
    return _dataGridController;
  }

  Widget _item(BrewModel model) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        leading: model.receipt != null && model.receipt!.ebc != null && model.receipt!.ebc! >= 0 ? Stack(
          children: [
            Container(
              child: Image.asset('assets/images/beer_1.png',
                color: ColorHelper.color(model.receipt!.ebc!) ?? SRM_COLORS[0],
                colorBlendMode: BlendMode.modulate
              ),
              width: 30,
              height: 50,
            ),
            Container(
              // color: SRM[model.getSRM()],
              child: Image.asset('assets/images/beer_2.png'),
              width: 30,
              height: 50,
            ),
          ]
        ) : Container(
          width: 30,
          height: 50,
        ),
        title: RichText(
          textAlign: TextAlign.left,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              TextSpan(text: '#${model.reference}', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: '  - ${AppLocalizations.of(context)!.datetimeFormat(model.inserted_at)}'),
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
                  if (model.receipt != null) TextSpan(text: '${AppLocalizations.of(context)!.text('receipt')} : '),
                  if (model.receipt != null) TextSpan(text: AppLocalizations.of(context)!.localizedText(model.receipt!.title), style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  if (model.tank != null) TextSpan(text: '${AppLocalizations.of(context)!.text('tank')} : '),
                  if (model.tank != null) TextSpan(text: model.tank!.name, style: TextStyle(fontWeight: FontWeight.bold)),
                  if (model.tank != null && model.volume != null) TextSpan(text: '  -  '),
                  if (model.volume != null) TextSpan(text: '${AppLocalizations.of(context)!.text('mash_volume')} : '),
                  if (model.volume != null) TextSpan(text: AppLocalizations.of(context)!.volumeFormat(model.volume), style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            if (model.notes != null ) _text(AppLocalizations.of(context)!.localizedText(model.notes))
          ],
        ),
        trailing: model.isEditable() ? PopupMenuButton<String>(
          icon: Icon(Icons.more_vert),
          tooltip: AppLocalizations.of(context)!.text('options'),
          onSelected: (value) async {
            if (value == 'edit') {
              _edit(model);
            } else if (value == 'remove') {
              if (await DeleteDialog.model(context, model, forced: true)) {
                _fetch();
              }
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
        ) : null,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return BrewPage(model);
          }));
        },
        onLongPress: () {
          if (currentUser != null && (currentUser!.isAdmin() || model.creator == currentUser!.uuid)) {
            _edit(model);
          }
        },
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
      _data = Database().getBrews(user: currentUser!.uuid, ordered: true);
    });
  }

  _new() {
    BrewModel newModel = BrewModel();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormBrewPage(newModel);
    })).then((value) { _fetch(); });
  }

  _edit(BrewModel model) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormBrewPage(model);
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
        for (BrewModel model in _selected) {
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

