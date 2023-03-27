import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/tables/edit_sfdatagrid.dart';
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/models/hop_model.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/utils/localized_text.dart';
import 'package:bb/utils/quantity.dart';
import 'package:bb/widgets/containers/empty_container.dart';
import 'package:bb/widgets/containers/error_container.dart';
import 'package:bb/widgets/dialogs/delete_dialog.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

// External package
import 'package:expandable_text/expandable_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:xml/xml.dart';

class HopsPage extends StatefulWidget {
  bool? showCheckboxColumn;
  bool? showQuantity;
  ReceiptModel? receipt;
  HopsPage({Key? key, this.showCheckboxColumn = false, this.showQuantity = false, this.receipt}) : super(key: key);

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
      showCheckboxColumn: widget.showCheckboxColumn!,
      onChanged: (HopModel value) {
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
          child: FutureBuilder<List<HopModel>>(
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
                    columns: HopModel.columns(context: context, showQuantity: false),
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

  Widget _item(HopModel model) {
    Locale locale = AppLocalizations.of(context)!.locale;
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        title: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              TextSpan(text: model.localizedName(locale) ?? '', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  if (model.alpha != null) TextSpan(text: '${AppLocalizations.of(context)!.text('alpha')}: ${AppLocalizations.of(context)!.percent(model.alpha)}'),
                  if (model.alpha != null && model.beta != null) TextSpan(text: '   '),
                  if (model.beta != null) TextSpan(text: '${AppLocalizations.of(context)!.text('beta')}: ${AppLocalizations.of(context)!.percent(model.beta)}'),
                ],
              ),
            ),
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
      _data = Database().getHops(searchText: _searchQueryController.value.text, ordered: true);
    });
  }

  _new() {
    HopModel newModel = HopModel();
    // Navigator.push(context, MaterialPageRoute(builder: (context) {
    //   return FormProductPage(newModel);
    // })).then((value) { _fetch(); });
  }

  _edit(HopModel model) {
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
            final hops = document.findAllElements('Hops');
            for(XmlElement element in hops) {
              final model = HopModel(
                name: LocalizedText( map: { 'en': element.getElement('F_H_NAME')!.text}),
                alpha: double.tryParse(element.getElement('F_H_ALPHA')!.text),
                beta: double.tryParse(element.getElement('F_H_BETA')!.text),
                origin: LocalizedText.country(element.getElement('F_H_ORIGIN')!.text),
              );
              final desc = element.getElement('F_H_NOTES');
              if (desc != null && desc.text.isNotEmpty) {
                String text = desc.text.replaceAll(RegExp(r'\n'), '');
                text = desc.text.replaceAll(RegExp(r'\r'), '');
                text = desc.text.replaceAll('  ', '');
                model.notes = LocalizedText(map: { 'en': text.trim()});
              }
              int form = int.parse(element.getElement('F_H_FORM')!.text);
              switch (form) {
                case 2:
                  model.form = Hop.leaf;
                  break;
                case 0:
                  model.form = Hop.pellet;
                  break;
                case 1:
                  model.form = Hop.plug;
                  break;
                default:
                  model.form = Hop.other;
                  break;
              }
              int type = int.parse(element.getElement('F_H_TYPE')!.text);
              switch (type) {
                case 1:
                  model.type = Type.aroma;
                  break;
                case 0:
                  model.type = Type.bittering;
                  break;
                case 2:
                  model.type = Type.both;
                  break;
              }
              List<HopModel> list = await Database().getHops(name: model.name.toString());
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

