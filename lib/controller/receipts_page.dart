import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' as Foundation;
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/basket_page.dart';
import 'package:bb/controller/forms/form_receipt_page.dart';
import 'package:bb/controller/receipt_page.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:bb/models/style_model.dart';
import 'package:bb/utils/abv.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/basket_notifier.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/utils/edition_notifier.dart';
import 'package:bb/utils/ibu.dart';
import 'package:bb/utils/srm.dart';
import 'package:bb/widgets/containers/error_container.dart';
import 'package:bb/widgets/containers/filter_receipt_appbar.dart';
import 'package:bb/widgets/custom_drawer.dart';
import 'package:bb/widgets/image_animate_rotate.dart';

// External package
import 'package:badges/badges.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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
  int _baskets = 0;

  // Edition mode
  bool _editable = false;
  bool _remove = false;
  bool _hidden = false;

  SRM _srm = SRM();
  IBU _ibu = IBU();
  ABV _abv = ABV();
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
          Badge(
            position: BadgePosition.topEnd(top: 0, end: 3),
            animationDuration: Duration(milliseconds: 300),
            animationType: BadgeAnimationType.slide,
            showBadge: _baskets > 0,
            badgeContent: _baskets > 0 ? Text(
              _baskets.toString(),
              style: TextStyle(color: Colors.white),
            ) : null,
            child: IconButton(
              icon: Icon(Icons.shopping_cart_outlined),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return BasketPage();
                }));
              },
            ),
          ),
          if (currentUser != null && currentUser!.isAdmin()) PopupMenuButton(
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
      drawer: CustomDrawer(context),
      body: FutureBuilder<List<ReceiptModel>>(
        future: _receipts,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return CustomScrollView(
              slivers: [
                FilterReceiptAppBar(
                  srm: _srm,
                  ibu: _ibu,
                  abv: _abv,
                  selectedFermentations: _selectedFermentations,
                  styles: _styles,
                  selectedStyles: _selectedStyles,
                  onColorChanged: (start, end) {
                    setState(() {
                      _srm.start = start;
                      _srm.end = end;
                    });
                    _fetch();
                  },
                  onIBUChanged: (start, end) {
                    setState(() {
                      _ibu.start = start;
                      _ibu.end = end;
                    });
                    _fetch();
                  },
                  onAlcoholChanged: (start, end) {
                    setState(() {
                      _abv.start = start;
                      _abv.end = end;
                    });
                    _fetch();
                  },
                  onFermentationChanged: (value) {
                    debugPrint('onFermentationChanged');
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
        visible: _editable && currentUser != null && currentUser!.isAdmin(),
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
                    color: SRM_COLORS[SRM.parse(model.ebc!)],
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                      TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: <TextSpan>[
                            if (model.style != null && (model.ibu != null || model.abv != null)) TextSpan(text: ' - '),
                            if (model.ibu != null) TextSpan(text: ' IBU: '),
                            if (model.ibu != null)TextSpan(text: model.ibu.toString()),
                            if (model.ibu != null && model.abv != null) TextSpan(text: '   '),
                            if (model.abv != null) TextSpan(text: ' ABV: ${model.abv}%'),
                          ]
                      )
                    ],
                  ),
                ),
                if (model.text != null ) _text(model.text!)
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

  Widget _text(String text) {
    return Foundation.kIsWeb ? MarkdownBody(
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

  _clear() async {
    setState(() {
      _srm.clear();
      _srm.end = SRM_COLORS.length.toDouble();
      _ibu.clear();
      _abv.clear();
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
    final editionProvider = Provider.of<EditionNotifier>(context, listen: false);
    _editable = editionProvider.editable;
    final basketProvider = Provider.of<BasketNotifier>(context, listen: false);
    _baskets = basketProvider.size;
    basketProvider.addListener(() {
      if (!mounted) return;
      setState(() {
        _baskets = basketProvider.size;
      });
    });
    _fetch();
  }

  _fetch() async {
    _styles  = await Database().getStyles(fermentations: _selectedFermentations, ordered: true);
    List<ReceiptModel> list  = await Database().getReceipts(ordered: true);
    setState(() {
      _receipts = _filter(list);
    });
  }

  Future<List<ReceiptModel>> _filter<T>(List<ReceiptModel> list) async {
    List<ReceiptModel>? values = [];
    String? search =  _searchQueryController.text;
    for (ReceiptModel model in list) {
      _setFilter(model);
      if (search != null && search.length > 0) {
        if (!(model.title!.toLowerCase().contains(search.toLowerCase()))) {
          continue;
        }
      }
      if (model.ebc != null && _srm.start != null && _srm.start! > SRM.parse(model.ebc!)) continue;
      if (model.ebc != null && _srm.end != null && _srm.end! < SRM.parse(model.ebc!)) continue;
      if (model.ibu != null && _ibu.start != null && _ibu.start! > model.ibu!) continue;
      if (model.ibu != null && _ibu.end != null && _ibu.end! < model.ibu!) continue;
      if (model.abv != null && _abv.start != null && _abv.start! > model.abv!) continue;
      if (model.abv != null && _abv.end != null && _abv.end! < model.abv!) continue;
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
    if (model.ibu != null && (_ibu.min == 0.0 || model.ibu! < _ibu.min))  _ibu.min = model.ibu!;
    if (model.ibu != null && (_ibu.max == 0.0 || model.ibu! > _ibu.max)) _ibu.max = model.ibu!;
    if (model.abv != null && (_abv.min == 0.0 || model.abv! < _abv.min)) _abv.min = model.abv!;
    if (model.abv != null && (_abv.max == 0.0 || model.abv! > _abv.max))  _abv.max = model.abv!;
  }

  _new() async {
    ReceiptModel newArticle = ReceiptModel();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormReceiptPage(newArticle);
    })).then((value) {
      _fetch();
    });
  }
}

