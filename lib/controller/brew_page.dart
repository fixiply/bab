import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/forms/form_brew_page.dart';
import 'package:bab/controller/stepper_page.dart';
import 'package:bab/controller/tables/fermentables_data_table.dart';
import 'package:bab/controller/tables/fermentation_data_table.dart';
import 'package:bab/controller/tables/hops_data_table.dart';
import 'package:bab/controller/tables/mash_data_table.dart';
import 'package:bab/controller/tables/misc_data_table.dart';
import 'package:bab/controller/tables/yeasts_data_table.dart';
import 'package:bab/helpers/color_helper.dart';
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/models/brew_model.dart';
import 'package:bab/models/fermentable_model.dart';
import 'package:bab/models/hop_model.dart';
import 'package:bab/models/misc_model.dart';
import 'package:bab/models/recipe_model.dart';
import 'package:bab/models/yeast_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/changes_notifier.dart';
import 'package:bab/utils/constants.dart' as constants;
import 'package:bab/widgets/animated_action_button.dart';
import 'package:bab/widgets/basket_button.dart';
import 'package:bab/widgets/containers/carousel_container.dart';
import 'package:bab/widgets/custom_menu_anchor.dart';
import 'package:bab/widgets/paints/bezier_clipper.dart';
import 'package:bab/widgets/paints/circle_clipper.dart';

// External package
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

class BrewPage extends StatefulWidget {
  BrewModel model;
  BrewPage(this.model);

  @override
  _BrewPageState createState() => _BrewPageState();
}

class _BrewPageState extends State<BrewPage> {
  Key _key = UniqueKey();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      body: CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          expandedHeight: 235.0,
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).primaryColor,
          leading: IconButton(
            icon: DeviceHelper.isLargeScreen(context) ? const Icon(Icons.close) : const BackButtonIcon(),
            onPressed:() async {
              Navigator.pop(context);
            }
          ),
          flexibleSpace: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double top = constraints.biggest.height;
              return FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: top > 140 ? const EdgeInsets.only(left: 170, bottom: 15) : EdgeInsetsDirectional.only(start: 72, bottom: 16),
                title: RichText(
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: Theme.of(context).primaryTextTheme.titleLarge!,
                    children: <TextSpan>[
                      TextSpan(text: '#${widget.model.reference}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (widget.model.started_at != null && !DeviceHelper.isMobile(context)) TextSpan(text: '  - ${AppLocalizations.of(context)!.dateFormat(widget.model.started_at)}'),
                    ],
                  ),
                ),
                background: _backgroundFlexible(),
              );
            }
          ),
          actions: <Widget>[
            BasketButton(),
            if (constants.currentUser != null && (constants.currentUser!.isAdmin() || widget.model.creator == constants.currentUser!.uuid))
              IconButton(
                icon: const Icon(Icons.edit_note),
                tooltip: AppLocalizations.of(context)!.text('remove'),
                onPressed: () {
                  _edit(widget.model);
                },
              ),
            CustomMenuAnchor(
              showMeasures: true,
            )
          ],
        ),
        if (widget.model.recipe != null) SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: RichText(
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: DefaultTextStyle.of(context).style.copyWith(fontSize: 20),
                children: [
                  TextSpan(text: AppLocalizations.of(context)!.localizedText(widget.model.recipe!.title), style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (widget.model.recipe!.style != null) TextSpan(text: '  -  ${AppLocalizations.of(context)!.localizedText(widget.model.recipe!.style!.name)}'),
                ]
              )
            )
          )
        ),
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('${AppLocalizations.of(context)!.text('tank')} : ${widget.model.tank!.name ?? '-'}', overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: RichText(
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(text: '${AppLocalizations.of(context)!.text(DeviceHelper.isSmallScreen(context) ? 'volume' : 'mash_volume')} : '),
                              if (widget.model.volume != null) TextSpan(text: AppLocalizations.of(context)!.litterVolumeFormat(widget.model.volume), style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (widget.model.volume == null) TextSpan(text: AppLocalizations.of(context)!.text('not_applicable')),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: RichText(
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(text: '${AppLocalizations.of(context)!.text(DeviceHelper.isSmallScreen(context) ? 'mash' : 'mash_water')} : '),
                              if (widget.model.mash_water != null) TextSpan(text: AppLocalizations.of(context)!.litterVolumeFormat(widget.model.mash_water), style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (widget.model.mash_water == null) TextSpan(text: AppLocalizations.of(context)!.text('not_applicable')),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: RichText(
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(text: '${AppLocalizations.of(context)!.text(DeviceHelper.isSmallScreen(context) ? 'sparge' : 'sparge_water')} : '),
                              if (widget.model.mash_water != null) TextSpan(text: AppLocalizations.of(context)!.litterVolumeFormat(widget.model.sparge_water), style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (widget.model.mash_water == null) TextSpan(text: AppLocalizations.of(context)!.text('not_applicable')),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: RichText(
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(text: '${AppLocalizations.of(context)!.text(DeviceHelper.isSmallScreen(context) ? 'efficiency' : 'mash_efficiency')} : '),
                              if (widget.model.efficiency != null) TextSpan(text: AppLocalizations.of(context)!.percentFormat(widget.model.efficiency), style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (widget.model.efficiency == null) TextSpan(text: AppLocalizations.of(context)!.text('not_applicable')),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: RichText(
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(text: '${AppLocalizations.of(context)!.text(DeviceHelper.isSmallScreen(context) ? 'alcohol' : 'abv')} : '),
                              if (widget.model.abv != null) TextSpan(text: AppLocalizations.of(context)!.percentFormat(widget.model.abv), style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (widget.model.abv == null) TextSpan(text: AppLocalizations.of(context)!.text('not_applicable'))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]
                )
              ]
            )
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            FutureBuilder<List<FermentableModel>>(
              future: widget.model.recipe!.getFermentables(volume: widget.model.volume),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FermentablesDataTable(
                        data: snapshot.data,
                        title: Text(AppLocalizations.of(context)!.text('fermentables'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0)),
                        allowEditing: false, allowSorting: false, showCheckboxColumn: false
                    ),
                  );
                }
                return Container();
              }
            ),
            FutureBuilder<List<HopModel>>(
              future: widget.model.recipe!.gethops(volume: widget.model.volume),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: HopsDataTable(
                        data: snapshot.data,
                        title: Text(AppLocalizations.of(context)!.text('hops'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0)),
                        allowEditing: false, allowSorting: false, showCheckboxColumn: false
                    ),
                  );
                }
                return Container();
              }
            ),
            FutureBuilder<List<YeastModel>>(
              future: widget.model.recipe!.getYeasts(volume: widget.model.volume),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: YeastsDataTable(
                        data: snapshot.data,
                        title: Text(AppLocalizations.of(context)!.text('yeasts'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0)),
                        allowEditing: false, allowSorting: false, showCheckboxColumn: false
                    ),
                  );
                }
                return Container();
            }
            ),
            FutureBuilder<List<MiscModel>>(
              future: widget.model.recipe!.getMisc(volume: widget.model.volume),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MiscDataTable(
                        data: snapshot.data,
                        title: Text(AppLocalizations.of(context)!.text('miscellaneous'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0)),
                        allowEditing: false, allowSorting: false, showCheckboxColumn: false
                    ),
                  );
                }
                return Container();
              }
            ),
            if (widget.model.recipe!.mash != null && widget.model.recipe!.mash!.isNotEmpty) Padding(
              padding: const EdgeInsets.all(8.0),
              child: MashDataTable(
                data: widget.model.recipe!.mash,
                title: Text(AppLocalizations.of(context)!.text('mash'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0)),
                allowEditing: false, allowSorting: false, showCheckboxColumn: false
              )
            ),
            if (widget.model.fermentations!.isNotEmpty) Padding(
              padding: const EdgeInsets.all(8.0),
              child: FermentationDataTable(
                data: widget.model.fermentations,
                title: Text(AppLocalizations.of(context)!.text('fermentation'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0)),
                allowEditing: false, allowSorting: false, showCheckboxColumn: false
              )
            )
          ])
        ),
        SliverToBoxAdapter(child: CarouselContainer(recipe: widget.model.uuid)),
        if (widget.model.notes != null) SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ExpansionTile(
              initiallyExpanded: true,
              title: Text(AppLocalizations.of(context)!.text('notes'), style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
              children: <Widget>[
                Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
                    child: MarkdownBody(
                      data: AppLocalizations.of(context)!.localizedText(widget.model.notes),
                      fitContent: true,
                      shrinkWrap: true,
                      softLineBreak: true,
                      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(textAlign: WrapAlignment.start),
                    )
                )
              ]
            ),
          ),
        ),
      ]
    ),
    floatingActionButton: AnimatedActionButton(
      backgroundColor: Colors.redAccent,
      title: AppLocalizations.of(context)!.text(widget.model.started_at != null ? 'resume' : 'start'),
      icon: const Icon(Icons.play_circle_outline),
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
              return StepperPage(widget.model);
            })).then((value) {
        });
      },
      )
    );
  }

  RichText _fermentation(String title, int day, double temp) {
    return RichText(
      textAlign: TextAlign.left,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: <InlineSpan>[
          WidgetSpan(
              child: SizedBox(
                width: 90,
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              )
          ),
          TextSpan(text: '  :  $day ${AppLocalizations.of(context)!.text('days').toLowerCase()} ${AppLocalizations.of(context)!.text('to').toLowerCase()} ${AppLocalizations.of(context)!.tempFormat(temp)}'),
        ],
      ),
    );
  }

  _initialize() async {
    final changesProvider = Provider.of<ChangesNotifier>(context, listen: false);
    changesProvider.addListener(() {
      if (changesProvider.model == widget.model.recipe) {
        if (!mounted) return;
        setState(() {
          widget.model.recipe = changesProvider.model as RecipeModel;
          _key = UniqueKey();
        });
      }
    });
  }

  _edit(BrewModel model) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormBrewPage(model);
    })).then((value) {
      if (value != null) {
        setState(() {
          widget.model = value;
          _key = UniqueKey();
        });
      }
    });
  }

  _backgroundFlexible() {
    return Stack(
        children: [
          Opacity(
            //semi red clippath with more height and with 0.5 opacity
            opacity: 0.5,
            child: ClipPath(
              clipper: BezierClipper(), //set our custom wave clipper
              child: Container(
                color: Colors.black,
                height: 200,
              ),
            ),
          ),
          Row(
              children: [
                Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 30),
                        child: Image.asset('assets/images/beer_1.png',
                            color: ColorHelper.color(widget.model.recipe!.ebc) ?? Colors.white,
                            colorBlendMode: BlendMode.modulate
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 30),
                        child: Image.asset('assets/images/beer_2.png'),
                      ),
                    ]
                ),
                Expanded(
                    child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipPath(
                            clipper: CircleClipper(radius: 65), //set our custom wave clipper
                            child: Container(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: DeviceHelper.isDesktop ? 10 : 0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (widget.model.recipe!.ebc != null) Text('${AppLocalizations.of(context)!.colorUnit}: ${AppLocalizations.of(context)!.colorFormat(widget.model.recipe!.ebc)}', style: const TextStyle(fontSize: 18, color: Colors.white)),
                                if (widget.model.recipe!.ibu != null) Text('IBU: ${AppLocalizations.of(context)!.numberFormat(widget.model.recipe!.ibu)}', style: const TextStyle(fontSize: 18, color: Colors.white)),
                                if (widget.model.recipe!.abv != null) Text(AppLocalizations.of(context)!.percentFormat(widget.model.recipe!.abv)!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                              ],
                            ),
                          ),
                        ]
                    )
                )
              ]
          )
        ]);
  }
}
