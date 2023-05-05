import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/basket_page.dart';
import 'package:bb/controller/forms/form_brew_page.dart';
import 'package:bb/controller/forms/form_receipt_page.dart';
import 'package:bb/controller/tables/fermentables_data_table.dart';
import 'package:bb/controller/tables/hops_data_table.dart';
import 'package:bb/controller/tables/mash_data_table.dart';
import 'package:bb/controller/tables/misc_data_table.dart';
import 'package:bb/controller/tables/yeasts_data_table.dart';
import 'package:bb/helpers/color_helper.dart';
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/models/brew_model.dart';
import 'package:bb/models/fermentable_model.dart';
import 'package:bb/models/hop_model.dart';
import 'package:bb/models/misc_model.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:bb/models/yeast_model.dart';
import 'package:bb/utils/abv.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/basket_notifier.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/edition_notifier.dart';
import 'package:bb/utils/ibu.dart';
import 'package:bb/widgets/containers/carousel_container.dart';
import 'package:bb/widgets/custom_menu_button.dart';
import 'package:bb/widgets/custom_slider.dart';
import 'package:bb/widgets/paints/bezier_clipper.dart';
import 'package:bb/widgets/paints/circle_clipper.dart';
import 'package:bb/widgets/paints/gradient_slider_thumb_shape.dart';
import 'package:bb/widgets/paints/gradient_slider_track_shape.dart';

// External package
import 'package:badges/badges.dart' as badge;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ReceiptPage extends StatefulWidget {
  final ReceiptModel model;
  ReceiptPage(this.model);
  _ReceiptPageState createState() => new _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  // Edition mode
  bool _editable = false;
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
            icon: DeviceHelper.isDesktop ? Icon(Icons.close) : const BackButtonIcon(),
            onPressed:() async {
              Navigator.pop(context);
            }
          ),
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsets.only(left: 170, bottom: 15),
            title: Text(AppLocalizations.of(context)!.localizedText(widget.model.title)),
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
                          color: ColorHelper.color(widget.model.ebc) ?? SRM_COLORS[0],
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
                              if (widget.model.ebc != null) Text('${AppLocalizations.of(context)!.colorUnit}: ${AppLocalizations.of(context)!.colorFormat(widget.model.ebc)}', style: TextStyle(fontSize: 18, color: Colors.white)),
                              if (widget.model.ibu != null) Text('IBU: ${widget.model.localizedIBU(AppLocalizations.of(context)!.locale)}', style: TextStyle(fontSize: 18, color: Colors.white)),
                              if (widget.model.abv != null) Text(widget.model.localizedABV(AppLocalizations.of(context)!.locale)!, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
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
            if (widget.model.isEditable()) IconButton(
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
              units: true,
              onSelected: (value) {
                if (value is Unit) {
                  setState(() {
                    AppLocalizations.of(context)!.unit = value;
                  });
                }
              },
            )
          ],
        ),
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomSlider(AppLocalizations.of(context)!.text('oiginal_gravity'), widget.model.og ?? 1, 1, 1.2, 0.01,
                        format: NumberFormat("0.000", AppLocalizations.of(context)!.locale.toString())
                      )
                    ),
                    Expanded(
                      child: CustomSlider(AppLocalizations.of(context)!.text('final_gravity'), widget.model.fg ?? 1, 1, 1.2, 0.01,
                        format: NumberFormat("0.000", AppLocalizations.of(context)!.locale.toString())
                      )
                    ),
                    Expanded(
                      child: CustomSlider(AppLocalizations.of(context)!.text('abv'), widget.model.abv ?? 0, 0, MAX_ABV, 0.1,
                        format: NumberFormat("#0.#'%'", AppLocalizations.of(context)!.locale.toString())
                      )
                    )
                  ]
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${AppLocalizations.of(context)!.colorUnit} - ${AppLocalizations.of(context)!.text('color')}', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0)),
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 5,
                              trackShape: GradientRectSliderTrackShape(darkenInactive: false),
                              thumbColor: Theme.of(context).primaryColor,
                              overlayColor: Theme.of(context).primaryColor.withOpacity(.1),
                              thumbShape: GradientSliderThumbShape(ringColor: Theme.of(context).primaryColor, fillColor: FillColor, selectedValue: 10, max: AppLocalizations.of(context)!.maxColor),
                              valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                            ),
                            child: Slider(
                              value: AppLocalizations.of(context)!.color(widget.model.ebc)?.toDouble() ?? 0,
                              label: '${widget.model.ebc}',
                              min: 0,
                              max: AppLocalizations.of(context)!.maxColor.toDouble(),
                              divisions: AppLocalizations.of(context)!.maxColor,
                              onChanged: (values) {
                              },
                            )
                          )
                        ]
                      )
                    ),
                    Expanded(
                      child: CustomSlider(AppLocalizations.of(context)!.text('ibu'), widget.model.ibu ?? 0, 0, MAX_IBU, 0.1,
                          format: NumberFormat("#0.#", AppLocalizations.of(context)!.locale.toString())
                      )
                    ),
                  ]
                )
              ]
            )
          ),
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
                        child: Text('${AppLocalizations.of(context)!.text('style')} : ${AppLocalizations.of(context)!.localizedText(widget.model.style!.name) ?? '-'}')
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
                              TextSpan(text: '${AppLocalizations.of(context)!.text('pasting_efficiency')} : '),
                              TextSpan(text: AppLocalizations.of(context)!.percentFormat(widget.model.efficiency), style: TextStyle(fontWeight: FontWeight.bold)),
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
                              TextSpan(text: '${AppLocalizations.of(context)!.text('mash_volume')} : '),
                              TextSpan(text: AppLocalizations.of(context)!.volumeFormat(widget.model.volume), style: TextStyle(fontWeight: FontWeight.bold)),
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
                              TextSpan(text: '${AppLocalizations.of(context)!.text('boiling_time')} : '),
                              TextSpan(text: AppLocalizations.of(context)!.tempFormat(widget.model.boil), style: TextStyle(fontWeight: FontWeight.bold)),
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
        if (widget.model.text != null && widget.model.text!.isNotEmpty) SliverToBoxAdapter(
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
                      title: Text(AppLocalizations.of(context)!.text('features'),
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                    );
                  },
                  body: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(bottom: 12, left: 12, right: 12),
                    child: MarkdownBody(
                      data: AppLocalizations.of(context)!.localizedText(widget.model.text),
                      fitContent: true,
                      shrinkWrap: true,
                      softLineBreak: true,
                      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(textScaleFactor: 1.2, textAlign: WrapAlignment.start),
                    )
                  ),
                )
            ])
          ),
          ),
        SliverList(
          delegate: SliverChildListDelegate([
            FutureBuilder<List<FermentableModel>>(
              future: widget.model.getFermentables(),
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
              future: widget.model.gethops(),
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
              future: widget.model.getYeasts(),
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
              future: widget.model.getMisc(),
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
            if (widget.model.mash != null && widget.model.mash!.isNotEmpty) Padding(
              padding: EdgeInsets.all(8.0),
              child: MashDataTable(
                data: widget.model.mash,
                title: Text(AppLocalizations.of(context)!.text('mash'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0)),
                allowEditing: false, allowSorting: false, showCheckboxColumn: false
              )
            )
          ]
        )),
        SliverToBoxAdapter(child: CarouselContainer(receipt: widget.model.uuid)),
        ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _new,
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: AppLocalizations.of(context)!.text('new_brew'),
        child: const Icon(Icons.add)
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
    final provider = Provider.of<EditionNotifier>(context, listen: false);
    _editable = provider.editable;
  }

  _edit(ReceiptModel model) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormReceiptPage(model);
    }));
  }

  _new() async {
    BrewModel newModel = BrewModel(
      receipt: widget.model,
      volume: widget.model.volume
    );
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormBrewPage(newModel);
    }));
  }
}
