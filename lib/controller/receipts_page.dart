import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/basket_page.dart';
import 'package:bab/controller/forms/form_receipt_page.dart';
import 'package:bab/controller/receipt_page.dart';
import 'package:bab/helpers/color_helper.dart';
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/models/receipt_model.dart';
import 'package:bab/models/style_model.dart';
import 'package:bab/utils/abv.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/basket_notifier.dart';
import 'package:bab/utils/category.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/utils/ibu.dart';
import 'package:bab/widgets/animated_action_button.dart';
import 'package:bab/widgets/containers/error_container.dart';
import 'package:bab/widgets/containers/filter_receipt_appbar.dart';
import 'package:bab/widgets/custom_drawer.dart';
import 'package:bab/widgets/custom_menu_button.dart';
import 'package:bab/widgets/dialogs/delete_dialog.dart';
import 'package:bab/widgets/image_animate_rotate.dart';
import 'package:bab/widgets/search_text.dart';

// External package
import 'package:badges/badges.dart' as badge;
import 'package:expandable_text/expandable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

class ReceiptsPage extends StatefulWidget {
  ReceiptsPage({Key? key}) : super(key: key);

  @override
  _ReceiptsPageState createState() => _ReceiptsPageState();
}

class _ReceiptsPageState extends State<ReceiptsPage> with AutomaticKeepAliveClientMixin<ReceiptsPage> {
  TextEditingController _searchQueryController = TextEditingController();
  Future<List<ReceiptModel>>? _receipts;
  List<StyleModel> _styles = [];
  List<Category> _categories = [];
  int _baskets = 0;

  IBU _ibu = IBU();
  ABV _abv = ABV();
  bool _my_receips = true;
  ColorHelper _cu = ColorHelper();
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
      backgroundColor: Colors.white,
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
            badgeAnimation: const badge.BadgeAnimation.slide(
              // animationDuration: const Duration(milliseconds: 300),
            ),
            showBadge: _baskets > 0,
            badgeContent: _baskets > 0 ? Text(
              _baskets.toString(),
              style: const TextStyle(color: Colors.white),
            ) : null,
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return BasketPage();
                }));
              },
            ),
          ),
          if (DeviceHelper.isDesktop) IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.refresh),
            tooltip: AppLocalizations.of(context)!.text('refresh'),
            onPressed: () {
              _fetch();
            },
          ),
          CustomMenuButton(
            context: context,
            publish: false,
            filtered: false,
            archived: false,
            measures: true,
          )
        ]
      ),
      drawer: !DeviceHelper.isLargeScreen(context) && currentUser != null ? CustomDrawer(context) : null,
      body: RefreshIndicator(
        onRefresh: () => _fetch(),
        child: FutureBuilder<List<ReceiptModel>>(
          future: _receipts,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return CustomScrollView(
                slivers: [
                  FilterReceiptAppBar(
                    ibu: _ibu,
                    abv: _abv,
                    cu: _cu,
                    my_receips: _my_receips,
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
                    onMyChanged: (value) {
                      setState(() {
                        _my_receips = value;
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
                          _selectedCategories.clear();
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
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Center(
                        child: Text(snapshot.data!.isEmpty ? AppLocalizations.of(context)!.text('no_result') : '${snapshot.data!.length} ${AppLocalizations.of(context)!.text(snapshot.data!.length > 1 ? 'receipts': 'receipt')}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                      )
                    )
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
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
      ),
      floatingActionButton: Visibility(
        visible: currentUser != null,
        child: AnimatedActionButton(
          title: AppLocalizations.of(context)!.text('new_recipe'),
          icon: const Icon(Icons.add),
          onPressed: _new,
        )
        // child: FloatingActionButton(
        //   onPressed: _new,
        //   backgroundColor: Theme.of(context).primaryColor,
        //   tooltip: AppLocalizations.of(context)!.text('new_recipe'),
        //   child: const Icon(Icons.add)
        // )
      )
    );
  }

  Widget _item(ReceiptModel model) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        leading: model.ebc != null && model.ebc! >= 0 ? Stack(
          children: [
            SizedBox(
              child: Image.asset('assets/images/beer_1.png',
                color: ColorHelper.color(model.ebc) ?? Colors.white,
                colorBlendMode: BlendMode.modulate
              ),
              width: 30,
              height: 50,
            ),
            SizedBox(
              // color: SRM[model.getSRM()],
              child: Image.asset('assets/images/beer_2.png'),
              width: 30,
              height: 50,
            ),
          ]
        ) : const SizedBox(width: 30, height: 50),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            AppLocalizations.of(context)!.localizedText(model.title),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
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
                  if (model.style != null) TextSpan(text: AppLocalizations.of(context)!.localizedText(model.style!.name), style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (model.style != null && (model.ibu != null || model.abv != null)) const TextSpan(text: '  -  '),
                  if (model.ibu != null) TextSpan(text: 'IBU: ${AppLocalizations.of(context)!.numberFormat(model.ibu)}'),
                  if (model.ibu != null && model.abv != null) const TextSpan(text: '   '),
                  if (model.abv != null) TextSpan(text: ' ABV: ${AppLocalizations.of(context)!.percentFormat(model.abv)}'),
                ],
              ),
            ),
            if (model.text != null ) _text(AppLocalizations.of(context)!.localizedText(model.text))
          ],
        ),
        trailing: model.isEditable() ? PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
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
            return ReceiptPage(model);
          }));
        },
        onLongPress: model.isEditable() ? () {
          _edit(model);
        } : null,
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

  _clear() async {
    setState(() {
      _cu.clear();
      _ibu.clear();
      _abv.clear();
      _selectedFermentations.clear();
      _selectedCategories.clear();
    });
    _fetch();
  }

  _initialize() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (mounted) {
        _fetch();
      }
    });
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
    List<ReceiptModel> list = await Database().getReceipts(user: currentUser?.uuid, myData: _my_receips, ordered: true);
    _styles  = await Database().getStyles(fermentations: _selectedFermentations, ordered: true);
    if (mounted == true) {
      Category.populate(  _categories, _styles, AppLocalizations.of(context)!.locale);
      setState(() {
        _receipts = _filter(list);
      });
    }
  }

  Future<List<ReceiptModel>> _filter<T>(List<ReceiptModel> list) async {
    List<ReceiptModel>? values = [];
    String? search =  _searchQueryController.text;
    for (ReceiptModel model in list) {
      _setFilter(model);
      if (search.isNotEmpty) {
        if (!(AppLocalizations.of(context)!.localizedText(model.title).toLowerCase().contains(search.toLowerCase()))) {
          continue;
        }
      }
      if (model.ebc != null && _cu.start != null && AppLocalizations.of(context)!.fromSRM(_cu.start)! > model.ebc!) continue;
      if (model.ebc != null && _cu.end != null && AppLocalizations.of(context)!.fromSRM(_cu.end)! < model.ebc!) continue;
      if (model.ibu != null && _ibu.start != null && _ibu.start! > model.ibu!) continue;
      if (model.ibu != null && _ibu.end != null && _ibu.end! < model.ibu!) continue;
      if (model.abv != null && _abv.start != null && _abv.start! > model.abv!) continue;
      if (model.abv != null && _abv.end != null && _abv.end! < model.abv!) continue;
      if (_selectedFermentations.isNotEmpty) {
        if (!_styles.contains(model.style)) {
          continue;
        }
      }
      if (_selectedCategories.isNotEmpty) {
        var result = _selectedCategories.where((element) => element.styles!.contains(model.style));
        if (result.isEmpty) {
          continue;
        }
      }
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
    ReceiptModel newModel = ReceiptModel();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormReceiptPage(newModel);
    })).then((value) {
      _fetch();
    });
  }

  _edit(ReceiptModel model) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormReceiptPage(model.copy());
    })).then((value) {
      _fetch();
    });
  }
}

