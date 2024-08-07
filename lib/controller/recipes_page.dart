import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/forms/form_recipe_page.dart';
import 'package:bab/controller/recipe_page.dart';
import 'package:bab/helpers/color_helper.dart';
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/helpers/import_helper.dart';
import 'package:bab/models/recipe_model.dart';
import 'package:bab/models/style_model.dart';
import 'package:bab/utils/abv.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/category.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/database.dart';
import 'package:bab/utils/ibu.dart';
import 'package:bab/widgets/animated_action_button.dart';
import 'package:bab/widgets/basket_button.dart';
import 'package:bab/widgets/containers/error_container.dart';
import 'package:bab/widgets/containers/filter_recipe_appbar.dart';
import 'package:bab/widgets/custom_dismissible.dart';
import 'package:bab/widgets/custom_drawer.dart';
import 'package:bab/widgets/custom_menu_anchor.dart';
import 'package:bab/widgets/dialogs/delete_dialog.dart';
import 'package:bab/widgets/image_animate_rotate.dart';
import 'package:bab/widgets/search_text.dart';

// External package
import 'package:expandable_text/expandable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class RecipesPage extends StatefulWidget {
  RecipesPage({Key? key}) : super(key: key);

  @override
  _RecipesPageState createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> with AutomaticKeepAliveClientMixin<RecipesPage> {
  TextEditingController _searchQueryController = TextEditingController();
  Future<List<RecipeModel>>? _recipes;
  List<StyleModel> _styles = [];
  List<Category> _categories = [];

  IBU _ibu = IBU();
  ABV _abv = ABV();
  bool _my_receips = true;
  ColorHelper _cu = ColorHelper();
  // List<Fermentation> _selectedFermentations = [];
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
    super.build(context);
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
          BasketButton(),
          if (DeviceHelper.isDesktop) IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.refresh),
            tooltip: AppLocalizations.of(context)!.text('refresh'),
            onPressed: () {
              _fetch();
            },
          ),
          CustomMenuAnchor(
            importLabel: currentUser != null ? '${AppLocalizations.of(context)!.text('import_file')} BeerXML' : null,
            onSelected: (value) async {
              if (value == Menu.imported && currentUser != null) {
                ImportHelper.fromBeerXML(context, () {
                  _fetch();
                });
              }
            },
          )
        ]
      ),
      drawer: !DeviceHelper.isLargeScreen && currentUser != null ? CustomDrawer(context) : null,
      body: RefreshIndicator(
        onRefresh: () => _fetch(),
        child: FutureBuilder<List<RecipeModel>>(
          future: _recipes,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return CustomScrollView(
                slivers: [
                  FilterRecipeAppBar(
                    ibu: _ibu,
                    abv: _abv,
                    cu: _cu,
                    my_data: _my_receips,
                    // selectedFermentations: _selectedFermentations,
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
                    // onFermentationChanged: (value) {
                    //   setState(() {
                    //     if (_selectedFermentations.contains(value)) {
                    //       _selectedFermentations.remove(value);
                    //       _selectedCategories.clear();
                    //     } else {
                    //       _selectedFermentations.add(value);
                    //     }
                    //   });
                    //   _fetch();
                    // },
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
                        child: Text(snapshot.data!.isEmpty ? AppLocalizations.of(context)!.text('no_result') : '${snapshot.data!.length} ${AppLocalizations.of(context)!.text(snapshot.data!.length > 1 ? 'recipes': 'recipe')}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                      )
                    )
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                      RecipeModel model = snapshot.data![index];
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

  Widget _item(RecipeModel model) {
    if (model.isEditable() && !DeviceHelper.isDesktop) {
      return CustomDismissible(
        context,
        key: Key(model.uuid!),
        child: _card(model),
        onStart: () {
          _edit(model);
        },
        onEnd: () async {
          await _delete(model);
        }
      );
    }
    return _card(model);
  }

  Widget _card(RecipeModel model) {
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
            if (model.notes != null ) ExpandableText(
              model.notes,
              linkColor: Theme.of(context).primaryColor,
              expandText: AppLocalizations.of(context)!.text('show_more').toLowerCase(),
              collapseText: AppLocalizations.of(context)!.text('show_less').toLowerCase(),
              maxLines: DeviceHelper.isDesktop ? 5 : 3,
            )
          ],
        ),
        trailing: model.isEditable() && DeviceHelper.isDesktop ? PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          tooltip: AppLocalizations.of(context)!.text('options'),
          onSelected: (value) async {
            if (value == 'edit') {
              _edit(model);
            } else if (value == 'remove') {
              _delete(model);
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
            return RecipePage(model);
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
      // _selectedFermentations.clear();
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
    _fetch();
  }

  _fetch() async {
    List<RecipeModel> list = await Database().getRecipes(user: currentUser?.uuid, myData: _my_receips, ordered: true);
    _styles  = await Database().getStyles(ordered: true);
    if (mounted == true) {
      Category.populate(  _categories, _styles, AppLocalizations.of(context)!.locale);
      setState(() {
        _recipes = _filter(list);
      });
    }
  }

  Future<List<RecipeModel>> _filter<T>(List<RecipeModel> list) async {
    List<RecipeModel>? values = [];
    String? search =  _searchQueryController.text;
    for (RecipeModel model in list) {
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
      // if (_selectedFermentations.isNotEmpty) {
      //   if (!_styles.contains(model.style)) {
      //     continue;
      //   }
      // }
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

  _setFilter(RecipeModel model) {
    if (model.ibu != null && (_ibu.min == 0.0 || model.ibu! < _ibu.min))  _ibu.min = model.ibu!;
    if (model.ibu != null && (_ibu.max == 0.0 || model.ibu! > _ibu.max)) _ibu.max = model.ibu!;
    if (model.abv != null && (_abv.min == 0.0 || model.abv! < _abv.min)) _abv.min = model.abv!;
    if (model.abv != null && (_abv.max == 0.0 || model.abv! > _abv.max))  _abv.max = model.abv!;
  }

  _new() async {
    RecipeModel newModel = RecipeModel();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormRecipePage(newModel);
    })).then((value) {
      _fetch();
    });
  }

  _edit(RecipeModel model) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormRecipePage(model.copy());
    })).then((value) {
      _fetch();
    });
  }

  _delete(RecipeModel model) async {
    if (await DeleteDialog.model(context, model, forced: true)) {
      _fetch();
    }
  }
}

