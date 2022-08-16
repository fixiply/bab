import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' as Foundation;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/forms/form_receipt_page.dart';
import 'package:bb/controller/receipt_page.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:bb/models/style_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/utils/edition_notifier.dart';
import 'package:bb/widgets/containers/error_container.dart';
import 'package:bb/widgets/containers/filter_receipt_appbar.dart';
import 'package:bb/widgets/custom_drawer.dart';
import 'package:bb/widgets/image_animate_rotate.dart';
import 'package:expandable_text/expandable_text.dart';

// External package
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprintf/sprintf.dart';

class ReceiptsPage extends StatefulWidget {
  ReceiptsPage({Key? key}) : super(key: key);
  _ReceiptsPageState createState() => new _ReceiptsPageState();
}

class _ReceiptsPageState extends State<ReceiptsPage>  {
  TextEditingController _searchQueryController = TextEditingController();
  Future<List<ReceiptModel>>? _receipts;
  List<StyleModel>? _styles;

  // Edition mode
  bool _editable = false;
  bool _remove = false;
  bool _hidden = false;

  double? _startSRM;
  double? _endSRM;
  double? _startIBU;
  double? _endIBU;
  double? _startAlcohol;
  double? _endAlcohol;
  double _minIBU = 0.0;
  double _maxIBU = 0.0;
  double _minAlcohol = 0.0;
  double _maxAlcohol = 0.0;
  List<Fermentation> _selectedFermentations = [];
  List<StyleModel> _selectedStyles = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: _buildSearchField(),
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        actions: <Widget> [
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined),
            onPressed: () {
            },
          ),
          if (currentUser != null && currentUser!.isEditor()) PopupMenuButton(
            icon: Icon(Icons.more_vert),
            tooltip: AppLocalizations.of(context)!.text('display'),
            onSelected: (value) async {
              if (value == 1) {
                await Database().publishAll();
              } else if (value == 3) {
                bool checked = !_remove;
                if (checked) {
                  _hidden = false;
                }
                setState(() { _remove = checked; });
                _fetch();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              PopupMenuItem(
                value: 1,
                child: Text(AppLocalizations.of(context)!.text('publish_everything')),
              ),
              PopupMenuItem(
                value: 2,
                child: SwitchListTile(
                  value: _editable,
                  title: Text(AppLocalizations.of(context)!.text('edit'), softWrap: false),
                  onChanged: (value) async {
                    bool checked = !_editable;
                    Provider.of<EditionNotifier>(context, listen: false).setEditable(checked);
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setBool(EDIT_KEY, checked);
                    setState(() { _editable = checked; });
                    Navigator.pop(context);
                  },
                )
              ),
              PopupMenuItem(
                enabled: false,
                value: null,
                child: Text(AppLocalizations.of(context)!.text('filtered')),
              ),
              CheckedPopupMenuItem(
                child: Text(AppLocalizations.of(context)!.text('archives')),
                value: 3,
                checked: _remove,
              ),
              CheckedPopupMenuItem(
                child: Text(AppLocalizations.of(context)!.text('hidden')),
                value: 4,
                checked: _hidden,
              )
            ]
          ),
        ]
      ),
      drawer: _editable && currentUser != null && currentUser!.isEditor() ? CustomDrawer(context) : null,
      body: FutureBuilder<List<ReceiptModel>>(
        future: _receipts,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return CustomScrollView(
              slivers: [
                FilterReceiptAppBar(
                  startSRM: _startSRM,
                  endSRM: _endSRM,
                  minIBU: _minIBU,
                  maxIBU: _maxIBU,
                  minAlcohol: _minAlcohol,
                  maxAlcohol: _maxAlcohol,
                  startIBU: _startIBU,
                  endIBU: _endIBU,
                  startAlcohol: _startAlcohol,
                  endAlcohol: _endAlcohol,
                  selectedFermentations: _selectedFermentations,
                  styles: _styles,
                  selectedStyles: _selectedStyles,
                  onColorChanged: (start, end) {
                    setState(() {
                      _startSRM = start;
                      _endSRM = end;
                    });
                    _fetch();
                  },
                  onIBUChanged: (start, end) {
                    setState(() {
                      _startIBU = start;
                      _endIBU = end;
                    });
                    _fetch();
                  },
                  onAlcoholChanged: (start, end) {
                    setState(() {
                      _startAlcohol = start;
                      _endAlcohol = end;
                    });
                    _fetch();
                  },
                  onFermentationChanged: (value) {
                    setState(() {
                      if (_selectedFermentations.contains(value)) {
                        _selectedFermentations.remove(value);
                        _selectedStyles.clear();
                      } else {
                        _selectedFermentations.add(value);
                      }
                    });
                    _fetch();
                  },
                  onStyleChanged: (value) {
                    setState(() {
                      if (_selectedStyles.contains(value)) {
                        _selectedStyles.remove(value);
                      } else {
                        _selectedStyles.add(value);
                      }
                    });
                    _fetch();
                  },
                  onReset: () => _clear()
                ),
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 6.0),
                    child: Center(
                      child: Text(snapshot.data!.length == 0 ? AppLocalizations.of(context)!.text('no_result') : sprintf(AppLocalizations.of(context)!.text('beer(s)'), [snapshot.data!.length]), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                    )
                  )
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((
                      BuildContext context, int index) {
                    ReceiptModel model = snapshot.data![index];
                    return _item(model);
                  }, childCount: snapshot.data!.length)
                )
              ]
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
      floatingActionButton: Visibility(
        visible: _editable && currentUser != null && currentUser!.isEditor(),
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
    return  Container(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: FillColor
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
              child: TextField(
                controller: _searchQueryController,
                decoration: InputDecoration(
                  icon: Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child: Icon(Icons.search, color: Theme.of(context).primaryColor)
                  ),
                  hintText: AppLocalizations.of(context)!.text('search_hint'),
                  hintStyle: TextStyle(color: Theme.of(context).primaryColor),
                  border: InputBorder.none
                ),
                style: TextStyle(fontSize: 16.0),
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

  Widget _item(ReceiptModel model) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        children: [
          ListTile(
            leading: Stack(
              children: [
                Container(
                  // color: SRM[model.getSRM()],
                  child: Image.asset('assets/images/beer3.png',
                    color: SRM[model.getSRM()],
                    // colorBlendMode: BlendMode.modulate
                  ),
                  width: 30,
                  height: 50,
                ),
                Container(
                  // color: SRM[model.getSRM()],
                  child: Image.asset('assets/images/beer2.png'),
                  width: 30,
                  height: 50,
                ),
                if (model.status == Status.pending) Positioned(
                  top: 4.0,
                  right: 4.0,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Theme.of(context).primaryColor
                    ),
                    child: Icon(Icons.hourglass_empty, size: 14, color: Colors.white),
                  )
                ),
              ]
            ),
            // title: Text(alert.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).buttonColor)),
            title: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                model.title!,
                style: TextStyle(  fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      TextSpan(text: _style(model.style), style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ' - '),
                      TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: <TextSpan>[
                            TextSpan(text: ' IBU: '),
                            TextSpan(text: model.ibu.toString()),
                            TextSpan(text: '    ' +model.alcohol.toString() + '°'),
                          ]
                      )
                    ],
                  ),
                ),
                Foundation.kIsWeb ?
                  MarkdownBody(
                    data: model.text!,
                    fitContent: true,
                    shrinkWrap: true,
                    softLineBreak: true,
                    styleSheet: MarkdownStyleSheet(
                        textAlign: WrapAlignment.start
                    )
                  ) :
                  ExpandableText(
                    model.text!,
                    linkColor: Theme.of(context).primaryColor,
                    expandText: AppLocalizations.of(context)!.text('show_more').toLowerCase(),
                    collapseText: AppLocalizations.of(context)!.text('show_less').toLowerCase(),
                    maxLines: 3,
                  )
              ],
            ),
            // subtitle: model.text != null ? Text(model.text!, style: TextStyle(fontSize: 14)) : null,
            // trailing: _editable && currentUser != null && currentUser!.isAdmin() ? PopupMenuButton<String>(
            //     icon: Icon(Icons.more_vert),
            //     tooltip: AppLocalizations.of(context)!.text('options'),
            //     onSelected: (value) {
            //       if (value == 'edit') {
            //         _edit(model);
            //       } else if (value == 'remove') {
            //         DeleteDialog.model(context, model, forced: true);
            //       }
            //     },
            //     itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            //       PopupMenuItem(
            //         value: 'edit',
            //         child: Text(AppLocalizations.of(context)!.text('edit')),
            //       ),
            //       PopupMenuItem(
            //         value: 'remove',
            //         child: Text(AppLocalizations.of(context)!.text('remove')),
            //       ),
            //     ]
            // ) : null,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ReceiptPage(model);
              }));
            },
          )
        ]
      )
    );
  }

  _clear() async {
    setState(() {
      _startSRM = 0;
      _endSRM = SRM.length.toDouble();
      _startIBU = _minIBU;
      _endIBU = _maxIBU;
      _startAlcohol = _minAlcohol;
      _endAlcohol = _maxAlcohol;
      _selectedFermentations.clear();
      _selectedStyles.clear();
    });
    _fetch();
  }

  String _style(String? uuid) {
    for (StyleModel model in _styles!) {
      if (model.uuid == uuid) {
        return model.title!;
      }
    }
    return '';
  }

  _initialize() async {
    final provider = Provider.of<EditionNotifier>(context, listen: false);
    _editable = provider.editable;
    _fetch();
  }

  _fetch() async {
    _styles  = await Database().getStyles(fermentations: _selectedFermentations, ordered: true);
    List<ReceiptModel> receipts  = await Database().getReceipts(ordered: true);
    setState(() {
      _receipts = _filter(receipts);
    });
  }

  Future<List<ReceiptModel>> _filter<T>(List<ReceiptModel> receipts) async {
    List<ReceiptModel>? values = [];
    String? search =  _searchQueryController.text;
    for (ReceiptModel model in receipts) {
      _setFilter(model);
      if (search != null && search.length > 0) {
        if (!(model.title!.toLowerCase().contains(search.toLowerCase()))) {
          continue;
        }
      }
      if (_startSRM != null && _startSRM! > model.getSRM()) continue;
      if (_endSRM != null && _endSRM! < model.getSRM()) continue;
      if (_startIBU != null && _startIBU! > model.ibu!) continue;
      if (_endIBU != null && _endIBU! < model.ibu!) continue;
      if (_startAlcohol != null && _startAlcohol! > model.alcohol!) continue;
      if (_endAlcohol != null && _endAlcohol! < model.alcohol!) continue;
      if (_selectedFermentations.isNotEmpty) {
        if (!_styles!.contains(model.style)) {
          continue;
        }
      };
      if (_selectedStyles.isNotEmpty) {
        if (!_selectedStyles.contains(model.style)) {
          continue;
        }
      };
      values.add(model);
    }
    return values;
  }

  _setFilter(ReceiptModel model) {
    if (_minIBU == 0.0 || model.ibu! < _minIBU)  _minIBU = model.ibu!;
    if (_maxIBU == 0.0 || model.ibu! > _maxIBU) _maxIBU = model.ibu!;
    if (_minAlcohol == 0.0 || model.alcohol! < _minAlcohol) _minAlcohol = model.alcohol!;
    if (_maxAlcohol == 0.0 || model.alcohol! > _maxAlcohol)  _maxAlcohol = model.alcohol!;
  }

  _new() async {
    ReceiptModel newArticle = ReceiptModel();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormReceiptPage(newArticle);
    })).then((value) {
      _fetch();
    });
  }

  _edit(ReceiptModel model) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormReceiptPage(model);
    })).then((value) { _fetch(); });
  }
}

