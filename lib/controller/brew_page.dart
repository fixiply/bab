import 'package:bb/models/fermentable_model.dart';
import 'package:bb/models/hop_model.dart';
import 'package:bb/models/misc_model.dart';
import 'package:bb/models/yeast_model.dart';
import 'package:bb/utils/database.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/basket_page.dart';
import 'package:bb/controller/forms/form_brew_page.dart';
import 'package:bb/controller/stepper_page.dart';
import 'package:bb/controller/tables/fermentables_data_table.dart';
import 'package:bb/controller/tables/hops_data_table.dart';
import 'package:bb/controller/tables/mash_data_table.dart';
import 'package:bb/controller/tables/misc_data_table.dart';
import 'package:bb/controller/tables/yeasts_data_table.dart';
import 'package:bb/helpers/color_helper.dart';
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/models/brew_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/basket_notifier.dart';
import 'package:bb/utils/constants.dart' as CS;
import 'package:bb/utils/edition_notifier.dart';
import 'package:bb/widgets/containers/carousel_container.dart';
import 'package:bb/widgets/custom_menu_button.dart';
import 'package:bb/widgets/paints/bezier_clipper.dart';
import 'package:bb/widgets/paints/circle_clipper.dart';

// External package
import 'package:badges/badges.dart' as badge;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

class BrewPage extends StatefulWidget {
  final BrewModel model;
  BrewPage(this.model);
  _BrewPageState createState() => new _BrewPageState();
}

class _BrewPageState extends State<BrewPage> {
  // Edition mode
  bool _expanded = true;
  int _baskets = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          expandedHeight: 235.0,
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).primaryColor,
          leading: IconButton(
            icon: DeviceHelper.isLargeScreen(context) ? Icon(Icons.close) : const BackButtonIcon(),
            onPressed:() async {
              Navigator.pop(context);
            }
          ),
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsets.only(left: 170, bottom: 15),
            title: Text('#${AppLocalizations.of(context)!.localizedText(widget.model.reference)} - ${AppLocalizations.of(context)!.dateFormat(widget.model.started())}'),
            background: Stack(
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
                        padding: EdgeInsets.only(left: 30),
                        child: Image.asset('assets/images/beer_1.png',
                          color: ColorHelper.color(widget.model.receipt!.ebc) ?? SRM_COLORS[0],
                          colorBlendMode: BlendMode.modulate
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 30),
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
                              if (widget.model.receipt!.ebc != null) Text('${AppLocalizations.of(context)!.colorUnit}: ${AppLocalizations.of(context)!.colorFormat(widget.model.receipt!.ebc)}', style: TextStyle(fontSize: 18, color: Colors.white)),
                              if (widget.model.receipt!.ibu != null) Text('IBU: ${AppLocalizations.of(context)!.numberFormat(widget.model.receipt!.ibu)}', style: TextStyle(fontSize: 18, color: Colors.white)),
                              if (widget.model.receipt!.abv != null) Text(AppLocalizations.of(context)!.percentFormat(widget.model.receipt!.abv)!, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                        ),
                      ]
                    )
                  )
                ]
              )
            ]),
          ),
          actions: <Widget>[
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
            if (CS.currentUser != null && (CS.currentUser!.isAdmin() || widget.model.creator == CS.currentUser!.uuid))
              IconButton(
                icon: Icon(Icons.edit_note),
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
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: RichText(
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: DefaultTextStyle.of(context).style.copyWith(fontSize: 20),
                children: [
                  TextSpan(text: AppLocalizations.of(context)!.localizedText(widget.model.receipt!.title), style: TextStyle(fontWeight: FontWeight.w600)),
                  if (widget.model.receipt!.style! != null) TextSpan(text: '  -  ${AppLocalizations.of(context)!.localizedText(widget.model.receipt!.style!.name)}'),
                ]
              )
            )
          )
        ),
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('${AppLocalizations.of(context)!.text('tank')} : ${widget.model.tank!.name ?? '-'}', overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: RichText(
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(text: '${AppLocalizations.of(context)!.text(DeviceHelper.isSmallScreen(context) ? 'volume' : 'mash_volume')} : '),
                              if (widget.model.volume != null) TextSpan(text: AppLocalizations.of(context)!.volumeFormat(widget.model.volume), style: TextStyle(fontWeight: FontWeight.bold)),
                              if (widget.model.volume == null) TextSpan(text: '-'),
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
                        padding: EdgeInsets.all(8),
                        child: RichText(
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(text: '${AppLocalizations.of(context)!.text(DeviceHelper.isSmallScreen(context) ? 'mash' : 'mash_water')} : '),
                              if (widget.model.mash_water != null) TextSpan(text: AppLocalizations.of(context)!.volumeFormat(widget.model.mash_water), style: TextStyle(fontWeight: FontWeight.bold)),
                              if (widget.model.mash_water == null) TextSpan(text: '-'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: RichText(
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(text: '${AppLocalizations.of(context)!.text(DeviceHelper.isSmallScreen(context) ? 'sparge' : 'sparge_water')} : '),
                              if (widget.model.mash_water != null) TextSpan(text: AppLocalizations.of(context)!.volumeFormat(widget.model.sparge_water), style: TextStyle(fontWeight: FontWeight.bold)),
                              if (widget.model.mash_water == null) TextSpan(text: '-'),
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
                        padding: EdgeInsets.all(8),
                        child: RichText(
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(text: '${AppLocalizations.of(context)!.text(DeviceHelper.isSmallScreen(context) ? 'efficiency' : 'mash_efficiency')} : '),
                              if (widget.model.efficiency != null) TextSpan(text: AppLocalizations.of(context)!.percentFormat(widget.model.efficiency), style: TextStyle(fontWeight: FontWeight.bold)),
                              if (widget.model.efficiency == null) TextSpan(text: '-'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: RichText(
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(text: '${AppLocalizations.of(context)!.text(DeviceHelper.isSmallScreen(context) ? 'alcohol' : 'volume_alcohol')} : '),
                              if (widget.model.abv != null) TextSpan(text: AppLocalizations.of(context)!.percentFormat(widget.model.abv), style: TextStyle(fontWeight: FontWeight.bold)),
                              if (widget.model.abv == null) TextSpan(text: '-')
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
                if (snapshot.hasData) {
                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: FermentablesDataTable(
                        data: snapshot.data,
                        title: Text(AppLocalizations.of(context)!.text('fermentables'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0)),
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
                if (snapshot.hasData) {
                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: HopsDataTable(
                        data: snapshot.data,
                        title: Text(AppLocalizations.of(context)!.text('hops'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0)),
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
                if (snapshot.hasData) {
                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: YeastsDataTable(
                        data: snapshot.data,
                        title: Text(AppLocalizations.of(context)!.text('yeasts'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0)),
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
                if (snapshot.hasData) {
                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: MiscDataTable(
                        data: snapshot.data,
                        title: Text(AppLocalizations.of(context)!.text('miscellaneous'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0)),
                        allowEditing: false, allowSorting: false, showCheckboxColumn: false
                    ),
                  );
                }
                return Container();
              }
            ),
            if (widget.model.receipt!.mash != null && widget.model.receipt!.mash!.isNotEmpty) Padding(
              padding: EdgeInsets.all(8.0),
              child: MashDataTable(
                data: widget.model.receipt!.mash,
                title: Text(AppLocalizations.of(context)!.text('mash'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0)),
                allowEditing: false, allowSorting: false, showCheckboxColumn: false
              )
            )
          ])
        ),
        SliverToBoxAdapter(child: CarouselContainer(receipt: widget.model.uuid)),
        if (widget.model.notes != null) SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(8.0),
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                      title: Text(AppLocalizations.of(context)!.text('notes'),
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                    );
                  },
                  body: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(bottom: 12, left: 12, right: 12),
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
    floatingActionButton: FloatingActionButton.extended(
      backgroundColor: Colors.redAccent,
      label: Text(AppLocalizations.of(context)!.text(widget.model.status == Status.pending || widget.model.status == Status.stoped ? 'start' : 'resume')),
      icon: Icon(Icons.play_circle_outline),
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

  _initialize() async {
    final basketProvider = Provider.of<BasketNotifier>(context, listen: false);
    _baskets = basketProvider.size;
    basketProvider.addListener(() {
      if (!mounted) return;
      setState(() {
        _baskets = basketProvider.size;
      });
    });
  }

  _edit(BrewModel model) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormBrewPage(model);
    }));
  }

  _start() async {
    if (widget.model.inserted_at!.isAfter(DateTime.now())) {
      setState(() {
        widget.model.status = widget.model.status == Status.pending || widget.model.status == Status.stoped ? Status.started : Status.stoped;
      });
      widget.model.started_at = DateTime.now();
      Database().update(widget.model);
    } else {
      _showSnackbar(AppLocalizations.of(context)!.text('brew_start_error'));
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
