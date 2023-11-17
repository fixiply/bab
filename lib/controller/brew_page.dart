import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/forms/form_brew_page.dart';
import 'package:bab/controller/stepper_page.dart';
import 'package:bab/controller/tables/fermentables_data_table.dart';
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
import 'package:bab/utils/database.dart';
import 'package:bab/widgets/animated_action_button.dart';
import 'package:bab/widgets/basket_button.dart';
import 'package:bab/widgets/containers/carousel_container.dart';
import 'package:bab/widgets/custom_menu_button.dart';
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

  // Edition mode
  bool _expanded = true;

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
                onPressed: () {
                  _edit(widget.model);
                },
              ),
            CustomMenuButton(
              context: context,
              publish: false,
              filtered: false,
              archived: false,
              measures: true,
            )
          ],
        ),
        if (widget.model.receipt != null) SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: RichText(
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: DefaultTextStyle.of(context).style.copyWith(fontSize: 20),
                children: [
                  TextSpan(text: AppLocalizations.of(context)!.localizedText(widget.model.receipt!.title), style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (widget.model.receipt!.style != null) TextSpan(text: '  -  ${AppLocalizations.of(context)!.localizedText(widget.model.receipt!.style!.name)}'),
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
                              if (widget.model.volume == null) const TextSpan(text: 'NC'),
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
                              if (widget.model.mash_water == null) const TextSpan(text: 'NC'),
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
                              if (widget.model.mash_water == null) const TextSpan(text: 'NC'),
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
                              if (widget.model.efficiency == null) const TextSpan(text: 'NC'),
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
                              TextSpan(text: '${AppLocalizations.of(context)!.text(DeviceHelper.isSmallScreen(context) ? 'alcohol' : 'volume_alcohol')} : '),
                              if (widget.model.abv != null) TextSpan(text: AppLocalizations.of(context)!.percentFormat(widget.model.abv), style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (widget.model.abv == null) const TextSpan(text: 'NC')
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
              future: widget.model.receipt!.getFermentables(volume: widget.model.volume),
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
              future: widget.model.receipt!.gethops(volume: widget.model.volume),
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
              future: widget.model.receipt!.getYeasts(volume: widget.model.volume),
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
              future: widget.model.receipt!.getMisc(volume: widget.model.volume),
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
            if (widget.model.receipt!.mash != null && widget.model.receipt!.mash!.isNotEmpty) Padding(
              padding: const EdgeInsets.all(8.0),
              child: MashDataTable(
                data: widget.model.receipt!.mash,
                title: Text(AppLocalizations.of(context)!.text('mash'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0)),
                allowEditing: false, allowSorting: false, showCheckboxColumn: false
              )
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.text('fermentation'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0)),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.model.primaryDay() != null && widget.model.receipt!.primarytemp != null) _fermentation(
                        AppLocalizations.of(context)!.text('primary'),
                        widget.model.primaryDay()!,
                        widget.model.receipt!.primarytemp!,
                      ),
                      const SizedBox(width: 12),
                      if (widget.model.secondaryDay() != null && widget.model.receipt!.secondarytemp != null) _fermentation(
                        AppLocalizations.of(context)!.text('secondary'),
                        widget.model.secondaryDay()!,
                        widget.model.receipt!.secondarytemp!,
                      ),
                      const SizedBox(width: 12),
                      if (widget.model.tertiaryDay() != null && widget.model.receipt!.tertiarytemp != null) _fermentation(
                        AppLocalizations.of(context)!.text('tertiary'),
                        widget.model.tertiaryDay()!,
                        widget.model.receipt!.tertiarytemp!,
                      ),
                    ],
                  )
                ]
              )
            )
          ])
        ),
        SliverToBoxAdapter(child: CarouselContainer(receipt: widget.model.uuid)),
        if (widget.model.notes != null) SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ExpansionPanelList(
              elevation: 1,
              expandedHeaderPadding: EdgeInsets.zero,
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  _expanded = !isExpanded;
                });
              },
              children: [
                ExpansionPanel(
                  isExpanded: _expanded,
                  canTapOnHeader: true,
                  headerBuilder: (context, isExpanded) {
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                      title: Text(AppLocalizations.of(context)!.text('notes'),
                          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                    );
                  },
                  body: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
                    child: MarkdownBody(
                      data: AppLocalizations.of(context)!.localizedText(widget.model.notes),
                      fitContent: true,
                      shrinkWrap: true,
                      softLineBreak: true,
                      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(textScaleFactor: 1.2, textAlign: WrapAlignment.start),
                    )
                  ),
                )
              ]
            )
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
      if (changesProvider.model == widget.model.receipt) {
        if (!mounted) return;
        debugPrint('changesProvider ${changesProvider.model}');
        setState(() {
          widget.model.receipt = changesProvider.model as RecipeModel;
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

  _start() async {
    if (widget.model.inserted_at!.isAfter(DateTime.now())) {
      widget.model.started_at = DateTime.now();
      Database().update(widget.model);
    } else {
      _showSnackbar(AppLocalizations.of(context)!.text('brew_start_error'));
    }
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
                            color: ColorHelper.color(widget.model.receipt!.ebc) ?? Colors.white,
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
                                if (widget.model.receipt!.ebc != null) Text('${AppLocalizations.of(context)!.colorUnit}: ${AppLocalizations.of(context)!.colorFormat(widget.model.receipt!.ebc)}', style: const TextStyle(fontSize: 18, color: Colors.white)),
                                if (widget.model.receipt!.ibu != null) Text('IBU: ${AppLocalizations.of(context)!.numberFormat(widget.model.receipt!.ibu)}', style: const TextStyle(fontSize: 18, color: Colors.white)),
                                if (widget.model.receipt!.abv != null) Text(AppLocalizations.of(context)!.percentFormat(widget.model.receipt!.abv)!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
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

  _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 10)
      )
    );
  }
}
