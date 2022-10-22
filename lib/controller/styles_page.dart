import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as Foundation;

// Internal package
import 'package:bb/controller/basket_page.dart';
import 'package:bb/controller/forms/form_style_page.dart';
import 'package:bb/controller/style_page.dart';
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
import 'package:bb/widgets/containers/filter_style_appbar.dart';
import 'package:bb/widgets/custom_drawer.dart';
import 'package:bb/widgets/image_animate_rotate.dart';

// External package
import 'package:badges/badges.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprintf/sprintf.dart';

class StylesPage extends StatefulWidget {
  _StylesPageState createState() => new _StylesPageState();
}

class _StylesPageState extends State<StylesPage> {
  TextEditingController _searchQueryController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<StyleModel>>? _styles;
  int _baskets = 0;

  // Edition mode
  bool _editable = false;
  bool _remove = false;
  bool _hidden = false;

  SRM _srm = SRM();
  IBU _ibu = IBU();
  ABV _abv = ABV();
  List<Fermentation> _selectedFermentations = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: FillColor,
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
        drawer: CustomDrawer(context),
        body: FutureBuilder<List<StyleModel>>(
          future: _styles,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return CustomScrollView(
                slivers: [
                  FilterStyleAppBar(
                    srm: _srm,
                    ibu: _ibu,
                    abv: _abv,
                    selectedFermentations: _selectedFermentations,
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
                      setState(() {
                        if (_selectedFermentations.contains(value)) {
                          _selectedFermentations.remove(value);
                        } else {
                          _selectedFermentations.add(value);
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
                            child: Text(snapshot.data!.length == 0 ? AppLocalizations.of(context)!.text('no_result') : sprintf(AppLocalizations.of(context)!.text('style(s)'), [snapshot.data!.length]), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                        )
                    )
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((
                        BuildContext context, int index) {
                      StyleModel model = snapshot.data![index];
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

  Widget _item(StyleModel model) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            // title: Text(alert.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).buttonColor)),
            title: Text(model.title!),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      if (model.category != null) TextSpan(text: model.category, style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          if (model.category != null && (model.min_ibu != null || model.max_ibu!= null || model.min_abv != null || model.max_abv != null)) TextSpan(text: ' - '),
                          _between('IBU', model.min_ibu, model.max_ibu),
                          if ((model.min_ibu != null || model.max_abv != null) && (model.min_abv != null || model.max_abv != null)) TextSpan(text: '   '),
                          _between('ABV', model.min_abv, model.max_abv, trailing: '%'),
                        ]
                      )
                    ],
                  ),
                ),
                if (model.text != null) _text(model.text!)
              ]
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return StylePage(model);
              }));
            },
          )
        ]
      )
    );
  }

  TextSpan _between(String leading, double? min, double? max, {String? trailing = ''}) {
    if (min != null || max != null) {
      return TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(text: '$leading: '),
          if (min != null) TextSpan(text: '${min.toString()}$trailing'),
          if (min != null && max != null) TextSpan(text: ' ${AppLocalizations.of(context)!.text('to').toLowerCase()} '),
          if (max != null) TextSpan(text: '${max.toString()}$trailing')
        ]
      );
    }
    return TextSpan();
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
    });
    _fetch();
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
    List<StyleModel> list  = await Database().getStyles(ordered: true);
    setState(() {
      _styles = _filter(list);
    });
  }

  Future<List<StyleModel>> _filter<T>(List<StyleModel> list) async {
    List<StyleModel>? values = [];
    String? search =  _searchQueryController.text;
    for (StyleModel model in list) {
      _setFilter(model);
      if (search != null && search.length > 0) {
        if (!(model.title!.toLowerCase().contains(search.toLowerCase()))) {
          continue;
        }
      }
      if (model.min_ebc != null && _srm.start != null && _srm.start! > SRM.parse(model.min_ebc!)) continue;
      if (model.max_ebc != null && _srm.end != null && _srm.end! < SRM.parse(model.max_ebc!)) continue;
      if (model.min_ibu != null && _ibu.start != null && _ibu.start! > model.min_ibu!) continue;
      if (model.max_ibu != null && _ibu.end != null && _ibu.end! < model.max_ibu!) continue;
      if (model.min_abv != null && _abv.start != null && _abv.start! > model.min_abv!) continue;
      if (model.max_abv != null && _abv.end != null && _abv.end! < model.max_abv!) continue;
      if (_selectedFermentations.isNotEmpty) {
        if (!_selectedFermentations.contains(model.fermentation)) {
          continue;
        }
      };
      values.add(model);
    }
    return values;
  }

  _setFilter(StyleModel model) {
    if (model.min_ibu != null && (_ibu.min == 0.0 || model.min_ibu! < _ibu.min))  _ibu.min = model.min_ibu ?? 0;
    if (model.max_ibu != null && (_ibu.max == 0.0 || model.max_ibu! > _ibu.max)) _ibu.max = model.max_ibu ?? MAX_IBU;
    if (model.min_abv != null && (_abv.min == 0.0 || model.min_abv! < _abv.min)) _abv.min = model.min_abv ?? 0;
    if (model.max_abv != null && (_abv.max == 0.0 || model.max_abv! > _abv.max))  _abv.max = model.max_abv ?? MAX_ABV;
  }

  _new() {
    StyleModel newStyle = StyleModel();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormStylePage(newStyle);
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

