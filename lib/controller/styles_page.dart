import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/basket_page.dart';
import 'package:bb/controller/forms/form_style_page.dart';
import 'package:bb/controller/style_page.dart';
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/models/style_model.dart';
import 'package:bb/utils/abv.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/basket_notifier.dart';
import 'package:bb/utils/category.dart';
import 'package:bb/utils/color_units.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/utils/edition_notifier.dart';
import 'package:bb/utils/ibu.dart';
import 'package:bb/utils/locale_notifier.dart';
import 'package:bb/utils/localized_text.dart';
import 'package:bb/widgets/containers/error_container.dart';
import 'package:bb/widgets/containers/filter_style_appbar.dart';
import 'package:bb/widgets/custom_drawer.dart';
import 'package:bb/widgets/dialogs/delete_dialog.dart';
import 'package:bb/widgets/image_animate_rotate.dart';

// External package
import 'package:badges/badges.dart' as badge;
import 'package:expandable_text/expandable_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';
import 'package:xml/xml.dart';

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
  bool _editable = false;
  bool _remove = false;
  bool _hidden = false;

  ColorUnits _cu = ColorUnits();
  IBU _ibu = IBU();
  ABV _abv = ABV();
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
        title: _buildSearchField(),
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
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            tooltip: AppLocalizations.of(context)!.text('display'),
            onSelected: (value) async {
              if (value is Locale) {
                Provider.of<LocaleNotifier>(context, listen: false).set(value);
              } else if (value == 1) {
                _import();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              PopupMenuItem(
                enabled: false,
                value: null,
                child: Text(AppLocalizations.of(context)!.text('language')),
              ),
              CheckedPopupMenuItem(
                child: Text(AppLocalizations.of(context)!.text('english')),
                value: const Locale('en', 'US'),
                checked: const Locale('en', 'US') == AppLocalizations.of(context)!.locale,
              ),
              CheckedPopupMenuItem(
                child: Text(AppLocalizations.of(context)!.text('french')),
                value: const Locale('fr', 'FR'),
                checked: const Locale('fr', 'FR') == AppLocalizations.of(context)!.locale,
              ),
              if (currentUser != null && currentUser!.isAdmin()) PopupMenuItem(
                value: 1,
                child: Text('${AppLocalizations.of(context)!.text('import')} BJCP'),
              ),
            ]
          ),
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
                          child: Text(snapshot.data!.length == 0 ? AppLocalizations.of(context)!.text('no_result') : sprintf(AppLocalizations.of(context)!.text('style(s)'), [snapshot.data!.length]), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
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
              TextSpan(text: model.localizedName(AppLocalizations.of(context)!.locale) ?? '', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextSpan(text: '  ${model.uuid}' ?? ''),
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
                  if (model.category != null) TextSpan(text: model.localizedCategory(AppLocalizations.of(context)!.locale) ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (model.min_ibu != null || model.max_ibu != null || model.min_abv != null || model.max_abv != null) TextSpan(text: '  -  '),
                  _between('IBU', model.min_ibu, model.max_ibu),
                  if (model.min_ibu != null || model.max_ibu != null || model.min_abv != null || model.max_abv != null) TextSpan(text: '   '),
                  _between('ABV', model.min_abv, model.max_abv, trailing: '%'),
                ],
              ),
            ),
            if (model.text != null) _text(model.localizedText(AppLocalizations.of(context)!.locale)!)
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
      _cu.end = SRM_COLORS.length.toDouble();
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
        if (!(model.localizedName(AppLocalizations.of(context)!.locale)!.toLowerCase().contains(search.toLowerCase()))) {
          continue;
        }
      }
      if (model.min_srm != null && _cu.start != null && _cu.start! > model.min_srm!) continue;
      if (model.max_srm != null && _cu.end != null && _cu.end! < model.max_srm!) continue;
      if (model.min_ibu != null && _ibu.start != null && _ibu.start! > model.min_ibu!) continue;
      if (model.max_ibu != null && _ibu.end != null && _ibu.end! < model.max_ibu!) continue;
      if (model.min_abv != null && _abv.start != null && _abv.start! > model.min_abv!) continue;
      if (model.max_abv != null && _abv.end != null && _abv.end! < model.max_abv!) continue;
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

  _edit(StyleModel model) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormStylePage(model.copy());
    })).then((value) {
      _fetch();
    });
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
          final categories = document.findAllElements('category');
          for(XmlElement category in categories) {
            final subcategories = category.findAllElements('subcategory');
            for(XmlElement subcategory in subcategories) {
              final model = StyleModel(
                uuid: subcategory.getAttribute('id'),
                name: LocalizedText( map: { 'en': subcategory.getElement('name')!.text}),
                category: LocalizedText( map: { 'en': category.getElement('name')!.text}),
              );
              final impression = subcategory.getElement('impression');
              if (impression != null) {
                model.text = LocalizedText( map: { 'en': impression.text});
              }
              final stats = subcategory.getElement('stats');
              if (stats != null) {
                final ibu = stats.getElement('ibu');
                if (ibu != null) {
                  final low = ibu.getElement('low');
                  final high = ibu.getElement('high');
                  if (low != null) model.min_ibu = double.tryParse(low.text);
                  if (high != null) model.max_ibu = double.tryParse(high.text);
                }
                final srm = stats.getElement('srm');
                if (srm != null) {
                  final low = srm.getElement('low');
                  final high = srm.getElement('high');
                  if (low != null) model.min_srm = double.tryParse(low.text);
                  if (high != null) model.max_srm = double.tryParse(high.text);
                }
                final abv = stats.getElement('abv');
                if (abv != null) {
                  final low = abv.getElement('low');
                  final high = abv.getElement('high');
                  if (low != null) model.min_abv = double.tryParse(low.text);
                  if (high != null) model.max_abv = double.tryParse(high.text);
                }
              }
              Database().set(model.uuid!, model, ignoreAuth: true);
            }
          }
        } finally {
          EasyLoading.dismiss();
        }
      }
    } on PlatformException catch (e) {
      _showSnackbar("Unsupported operation" + e.toString());
    } catch (ex) {
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

