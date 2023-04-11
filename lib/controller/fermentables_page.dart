import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Internal package
import 'package:bb/controller/forms/form_fermentable_page.dart';
import 'package:bb/controller/tables/edit_sfdatagrid.dart';
import 'package:bb/controller/tables/fermentables_data_table.dart';
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/helpers/import_helper.dart';
import 'package:bb/models/fermentable_model.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/helpers/color_helper.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/utils/localized_text.dart';
import 'package:bb/widgets/containers/empty_container.dart';
import 'package:bb/widgets/containers/error_container.dart';
import 'package:bb/widgets/dialogs/delete_dialog.dart';
import 'package:bb/widgets/search_text.dart';

// External package
import 'package:expandable_text/expandable_text.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class FermentablesPage extends StatefulWidget {
  bool allowEditing;
  bool showCheckboxColumn;
  bool showQuantity;
  bool loadMore;
  ReceiptModel? receipt;
  FermentablesPage({Key? key, this.allowEditing = false, this.showCheckboxColumn = false, this.showQuantity = false, this.loadMore = false, this.receipt}) : super(key: key);

  _FermentablesPageState createState() => new _FermentablesPageState();
}

class _FermentablesPageState extends State<FermentablesPage> with AutomaticKeepAliveClientMixin<FermentablesPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late FermentableDataSource _dataSource;
  final DataGridController _dataGridController = DataGridController();
  final TextEditingController _searchQueryController = TextEditingController();
  ScrollController? _controller;
  Future<List<FermentableModel>>? _data;
  List<FermentableModel> _selected = [];
  bool _showList = false;

  List<FermentableModel> get selected => _selected;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _dataSource = FermentableDataSource(context,
      showQuantity: widget.showQuantity,
      showCheckboxColumn: widget.showCheckboxColumn,
      onChanged: (FermentableModel value, int dataRowIndex) {
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
                ImportHelper.yeasts(context, () {
                  _fetch();
                });
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
          child: FutureBuilder<List<FermentableModel>>(
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
                    controller: _dataGridController,
                    onSelectionChanged: (List<DataGridRow> addedRows, List<DataGridRow> removedRows) {
                      for(var row in addedRows) {
                        final index = _dataSource.rows.indexOf(row);
                        _selected.add(snapshot.data![index]);
                      }
                      for(var row in removedRows) {
                        final index = _dataSource.rows.indexOf(row);
                        _selected.remove(snapshot.data![index]);
                      }
                    },
                    columns: FermentableDataSource.columns(context: context, showQuantity: false),
                  );
                }
                return ListView.builder(
                  controller: _controller,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: snapshot.hasData ? snapshot.data!.length : 0,
                  itemBuilder: (context, index) {
                    FermentableModel model = snapshot.data![index];
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
        visible: currentUser != null && currentUser!.isAdmin(),
        child: FloatingActionButton(
          onPressed: _new,
          backgroundColor: Theme.of(context).primaryColor,
          tooltip: AppLocalizations.of(context)!.text('new'),
          child: const Icon(Icons.add)
        )
      )
    );
  }

  Widget _item(FermentableModel model) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        leading: model.ebc != null && model.ebc! >= 0 ? Stack(
          children: [
            Container(
              // color: SRM[model.getSRM()],
              child: Image.asset('assets/images/beer_1.png',
                color: ColorHelper.color(model.ebc) ?? SRM_COLORS[0],
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
                  if (model.ebc != null || model.efficiency != null) TextSpan(text: '  -  '),
                  if (model.ebc != null) TextSpan(text: '${AppLocalizations.of(context)!.colorUnit}: ${AppLocalizations.of(context)!.numberFormat(model.ebc)}'),
                  if (model.ebc != null && model.efficiency != null) TextSpan(text: '   '),
                  if (model.efficiency != null) TextSpan(text: '${AppLocalizations.of(context)!.text('yield')}: ${AppLocalizations.of(context)!.percentFormat(model.efficiency)}'),
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
      _data = Database().getFermentables(searchText: _searchQueryController.value.text, ordered: true);
    });
  }

  _new() {
    FermentableModel newModel = FermentableModel();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormFermentablePage(newModel);
    })).then((value) { _fetch(); });
  }

  _edit(FermentableModel model) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormFermentablePage(model);
    })).then((value) { _fetch(); });
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

