import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/tables/edit_sfdatagrid.dart';
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/models/miscellaneous_model.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/utils/localized_text.dart';
import 'package:bb/utils/quantity.dart';
import 'package:bb/widgets/containers/empty_container.dart';
import 'package:bb/widgets/containers/error_container.dart';
import 'package:bb/widgets/dialogs/delete_dialog.dart';

// External package
import 'package:expandable_text/expandable_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:xml/xml.dart';

class MiscellaneousPage extends StatefulWidget {
  bool? showCheckboxColumn;
  bool? showQuantity;
  ReceiptModel? receipt;
  MiscellaneousPage({Key? key, this.showCheckboxColumn = false, this.showQuantity = false, this.receipt}) : super(key: key);

  _MiscellaneousPageState createState() => new _MiscellaneousPageState();
}

class _MiscellaneousPageState extends State<MiscellaneousPage> with AutomaticKeepAliveClientMixin<MiscellaneousPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late MiscellaneousDataSource _dataSource;
  final DataGridController _dataGridController = DataGridController();
  final TextEditingController _searchQueryController = TextEditingController();
  ScrollController? _controller;
  Future<List<MiscellaneousModel>>? _data;
  List<MiscellaneousModel> _selected = [];
  bool _showList = false;

  List<MiscellaneousModel> get selected => _selected;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _dataSource = MiscellaneousDataSource(context,
      showQuantity: widget.showQuantity,
      showCheckboxColumn: widget.showCheckboxColumn!,
      onChanged: (MiscellaneousModel value) {
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
        title: _buildSearchField(),
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
          if (currentUser != null && currentUser!.isAdmin()) IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.download_outlined),
            tooltip: AppLocalizations.of(context)!.text('import'),
            onPressed: _import,
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
          child: FutureBuilder<List<MiscellaneousModel>>(
            future: _data,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.length == 0) {
                  return EmptyContainer(message: AppLocalizations.of(context)!.text('no_result'));
                }
                if (_showList || widget.showCheckboxColumn == true) {
                  _dataSource.buildDataGridRows(snapshot.data!);
                  return EditSfDataGrid(
                    context,
                    allowEditing: currentUser != null && currentUser!.isAdmin(),
                    showCheckboxColumn: widget.showCheckboxColumn!,
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
                    columns: MiscellaneousModel.columns(context: context, showQuantity: false),
                  );
                }
                return ListView.builder(
                  controller: _controller,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: snapshot.hasData ? snapshot.data!.length : 0,
                  itemBuilder: (context, index) {
                    MiscellaneousModel model = snapshot.data![index];
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

  Widget _item(MiscellaneousModel model) {
    Locale locale = AppLocalizations.of(context)!.locale;
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        title: Text(model.localizedName(locale) ?? '',  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (model.type != Misc.other) Text(AppLocalizations.of(context)!.text(model.type.toString().toLowerCase()), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
            if (model.notes != null ) ExpandableText(
              model.localizedNotes(locale) ?? '',
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
    MiscellaneousModel newModel = MiscellaneousModel();
    // Navigator.push(context, MaterialPageRoute(builder: (context) {
    //   return FormProductPage(newModel);
    // })).then((value) { _fetch(); });
  }

  _edit(MiscellaneousModel model) {
    // Navigator.push(context, MaterialPageRoute(builder: (context) {
    //   return FormProductPage(model);
    // })).then((value) { _fetch(); });
  }

  _import() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xml'],
      );
      if (result != null) {
        try {
          EasyLoading.show(status: AppLocalizations.of(context)!.text('in_progress'));

          final XmlDocument document;
          if(DeviceHelper.isDesktop) {
            document = XmlDocument.parse(utf8.decode(result.files.single.bytes!));
          } else {
            File file = File(result.files.single.path!);
            document = XmlDocument.parse(file.readAsStringSync());
          }
          if (document != null) {
            final fermentables = document.findAllElements('Misc');
            for(XmlElement element in fermentables) {
              final model = MiscellaneousModel(
                  name: LocalizedText( map: { 'en': element.getElement('F_M_NAME')!.text})
              );
              int? time = int.tryParse(element.getElement('F_M_TIME')!.text);
              if (time != null) {
                model.time = time;
              }
              final desc = element.getElement('F_M_NOTES');
              if (desc != null && desc.text.isNotEmpty) {
                String text = desc.text.replaceAll(RegExp(r'\n'), '');
                text = desc.text.replaceAll(RegExp(r'\r'), '');
                text = desc.text.replaceAll('  ', '');
                model.notes = LocalizedText(map: { 'en': text.trim()});
              }
              int type = int.parse(element.getElement('F_M_TYPE')!.text);
              switch (type) {
                case 0:
                  model.type = Misc.spice;
                  break;
                case 1:
                  model.type = Misc.fining;
                  break;
                case 2:
                  model.type = Misc.herb;
                  break;
                case 3:
                  model.type = Misc.flavor;
                  break;
                case 4:
                  model.type = Misc.other;
                  break;
                case 5:
                  model.type = Misc.water_agent;
                  break;
              }
              int use = int.parse(element.getElement('F_M_USE')!.text);
              switch (use) {
                case 0:
                  model.use = Use.boil;
                  break;
                case 1:
                  model.use = Use.mash;
                  break;
                case 2:
                  model.use = Use.primary;
                  break;
                case 3:
                  model.use = Use.secondary;
                  break;
                case 4:
                  model.use = Use.bottling;
                  break;
                case 5:
                  model.use = Use.sparge;
                  break;
              }
              List<MiscellaneousModel> list = await Database().getMiscellaneous(name: model.name.toString());
              if (list.isEmpty) {
                Database().add(model, ignoreAuth: true);
              }
            }
            _fetch();
          }
        } finally {
          EasyLoading.dismiss();
        }
      }
    } on PlatformException catch (e) {
      _showSnackbar("Unsupported operation" + e.toString());
    } catch (ex) {
      debugPrint(ex.toString());
      _showSnackbar(ex.toString());
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

