import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/basket_page.dart';
import 'package:bb/controller/forms/form_style_page.dart';
import 'package:bb/controller/style_page.dart';
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/helpers/import_helper.dart';
import 'package:bb/models/style_model.dart';
import 'package:bb/utils/abv.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/basket_notifier.dart';
import 'package:bb/utils/category.dart';
import 'package:bb/utils/color_units.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/utils/ibu.dart';
import 'package:bb/widgets/containers/error_container.dart';
import 'package:bb/widgets/containers/filter_style_appbar.dart';
import 'package:bb/widgets/custom_drawer.dart';
import 'package:bb/widgets/custom_menu_button.dart';
import 'package:bb/widgets/dialogs/delete_dialog.dart';
import 'package:bb/widgets/image_animate_rotate.dart';
import 'package:bb/widgets/search_text.dart';

// External package
import 'package:badges/badges.dart' as badge;
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StylesPage extends StatefulWidget {
  StylesPage({Key? key}) : super(key: key);
  _StylesPageState createState() => new _StylesPageState();
}

class _StylesPageState extends State<StylesPage> with AutomaticKeepAliveClientMixin<StylesPage> {
  TextEditingController _searchQueryController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<StyleModel>>? _styles;
  List<Category> _categories = [];
  int _baskets = 0;

  // Edition mode
  IBU _ibu = IBU();
  ABV _abv = ABV();
  ColorUnits _cu = ColorUnits();
  List<Fermentation> _selectedFermentations = [];
  List<Category> _selectedCategories = [];

  @override
  bool get wantKeepAlive => true;

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
        title: SearchText(
          _searchQueryController,
          () {  _fetch(); }
        ),
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        actions: <Widget> [
          badge.Badge(
            position: badge.BadgePosition.topEnd(top: 0, end: 3),
            animationDuration: Duration(milliseconds: 300),
            animationType: badge.BadgeAnimationType.slide,
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
          CustomMenuButton(
            context: context,
            publish: false,
            filtered: false,
            archived: false,
            units: true,
            onSelected: (value) async {
              if (value == 'import') {
                ImportHelper.styles(context, () {
                  _fetch();
                });
              } else if (value is Unit) {
                _clear();
                setState(() {
                  AppLocalizations.of(context)!.unit = value;
                });
              }
            },
            joints: (List<PopupMenuEntry> items) {
              if (currentUser != null && currentUser!.isAdmin()) {
                items.add(PopupMenuDivider(height: 5));
                items.add(PopupMenuItem(
                  value: 'import',
                  child: Text('${AppLocalizations.of(context)!.text('import')} BJCP'),
                ));
              }
            }
            )
        ]
      ),
      drawer: !DeviceHelper.isDesktop && currentUser != null && currentUser!.hasRole() ? CustomDrawer(context) : null,
      body: FutureBuilder<List<StyleModel>>(
        future: _styles,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return CustomScrollView(
              slivers: [
                FilterStyleAppBar(
                  cu: _cu,
                  ibu: _ibu,
                  abv: _abv,
                  selectedFermentations: _selectedFermentations,
                  categories: _categories,
                  selectedCategories: _selectedCategories,
                  onColorChanged: (start, end) {
                    setState(() {
                      _cu.start = start;
                      _cu.end = end;
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
                  onCategoryChanged: (value) {
                    setState(() {
                      if (_selectedCategories.contains(value)) {
                        _selectedCategories.remove(value);
                      } else {
                        _selectedCategories.add(value);
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
                        child: Text(snapshot.data!.length == 0 ? AppLocalizations.of(context)!.text('no_result') : '${snapshot.data!.length} ${AppLocalizations.of(context)!.text(snapshot.data!.length > 1 ? 'styles': 'style')}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                    )
                  )
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
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

  Widget _item(StyleModel model) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        title: RichText(
          textAlign: TextAlign.left,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              TextSpan(text: AppLocalizations.of(context)!.localizedText(model.name), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextSpan(text: '  ${model.number}' ?? ''),
            ],
          ),
        ),
        // title: Text('${model.localizedName(AppLocalizations.of(context)!.locale) ${model.uuid}}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  if (model.category != null) TextSpan(text: AppLocalizations.of(context)!.localizedText(model.category), style: TextStyle(fontWeight: FontWeight.bold)),
                  if (model.ibumin != null || model.ibumax != null || model.abvmin != null || model.abvmax != null) TextSpan(text: '  -  '),
                  _between('IBU', model.ibumin, model.ibumax),
                  if (model.ibumin != null || model.ibumax != null || model.abvmin != null || model.abvmax != null) TextSpan(text: '   '),
                  _between('ABV', model.abvmin, model.abvmax, trailing: '%'),
                ],
              ),
            ),
            if (model.overallimpression != null) _text(AppLocalizations.of(context)!.localizedText(model.overallimpression))
          ]
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
            return StylePage(model);
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

  TextSpan _between(String label, double? min, double? max, {String? trailing = ''}) {
    if (min != null || max != null) {
      return TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(text: '$label: '),
          if (min != null) TextSpan(text: '${NumberFormat("#0.#", AppLocalizations.of(context)!.locale.toString()).format(min)}$trailing'),
          if (min != null && max != null) TextSpan(text: ' ${AppLocalizations.of(context)!.text('to').toLowerCase()} '),
          if (max != null) TextSpan(text: '${NumberFormat("#0.#", AppLocalizations.of(context)!.locale.toString()).format(max)}$trailing')
        ]
      );
    }
    return TextSpan();
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

  _clear() async {
    setState(() {
      _cu.clear();
      _ibu.clear();
      _abv.clear();
      _selectedFermentations.clear();
    });
    _fetch();
  }

  _initialize() async {
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
    List<StyleModel> list = await Database().getStyles(ordered: true);
    Category.populate(_categories, list, AppLocalizations.of(context)!.locale);
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
        if (!(AppLocalizations.of(context)!.localizedText(model.name).toLowerCase().contains(search.toLowerCase())) &&
          !(AppLocalizations.of(context)!.localizedText(model.category).toLowerCase().contains(search.toLowerCase()))) {
          continue;
        }
      }
      if (model.ebcmin != null && _cu.start != null && AppLocalizations.of(context)!.fromSRM(_cu.start)! > model.ebcmin!) continue;
      if (model.ebcmax != null && _cu.end != null && AppLocalizations.of(context)!.fromSRM(_cu.end)! < model.ebcmax!) continue;
      if (model.ibumin != null && _ibu.start != null && _ibu.start! > model.ibumin!) continue;
      if (model.ibumax != null && _ibu.end != null && _ibu.end! < model.ibumax!) continue;
      if (model.abvmin != null && _abv.start != null && _abv.start! > model.abvmin!) continue;
      if (model.abvmax != null && _abv.end != null && _abv.end! < model.abvmax!) continue;
      if (_selectedFermentations.isNotEmpty) {
        if (!_selectedFermentations.contains(model.fermentation)) {
          continue;
        }
      };
      if (_selectedCategories.isNotEmpty) {
        var result = _selectedCategories.where((element) => element.styles!.contains(model));
        if (result.isEmpty) {
          continue;
        }
      };
      values.add(model);
    }
    return values;
  }

  _setFilter(StyleModel model) {
    if (model.ibumin != null && (_ibu.min == 0.0 || model.ibumin! < _ibu.min))  _ibu.min = model.ibumin ?? 0;
    if (model.ibumax != null && (_ibu.max == 0.0 || model.ibumax! > _ibu.max)) _ibu.max = model.ibumax ?? MAX_IBU;
    if (model.abvmin != null && (_abv.min == 0.0 || model.abvmin! < _abv.min)) _abv.min = model.abvmin ?? 0;
    if (model.abvmax != null && (_abv.max == 0.0 || model.abvmax! > _abv.max))  _abv.max = model.abvmax ?? MAX_ABV;
  }

  _new() {
    StyleModel newStyle = StyleModel();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormStylePage(newStyle);
    })).then((value) { _fetch(); });
  }

  _edit(StyleModel model) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormStylePage(model.copy());
    })).then((value) {
      _fetch();
    });
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

