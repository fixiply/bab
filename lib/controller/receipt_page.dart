import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;

// Internal package
import 'package:bab/controller/forms/form_brew_page.dart';
import 'package:bab/controller/forms/form_receipt_page.dart';
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
import 'package:bab/models/receipt_model.dart';
import 'package:bab/models/yeast_model.dart';
import 'package:bab/utils/abv.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/ibu.dart';
import 'package:bab/widgets/animated_action_button.dart';
import 'package:bab/widgets/basket_button.dart';
import 'package:bab/widgets/containers/carousel_container.dart';
import 'package:bab/widgets/containers/ratings_container.dart';
import 'package:bab/widgets/custom_menu_button.dart';
import 'package:bab/widgets/custom_slider.dart';
import 'package:bab/widgets/paints/bezier_clipper.dart';
import 'package:bab/widgets/paints/circle_clipper.dart';
import 'package:bab/widgets/paints/gradient_slider_thumb_shape.dart';
import 'package:bab/widgets/paints/gradient_slider_track_shape.dart';

// External package
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReceiptPage extends StatefulWidget {
  ReceiptModel model;
  ReceiptPage(this.model);

  @override
  _ReceiptPageState createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  Key _key = UniqueKey();

  // Edition mode
  bool _expanded = true;

  double _rating = 0;
  int _notices = 0;

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
                title: Text(AppLocalizations.of(context)!.localizedText(widget.model.title)),
                background: _backgroundFlexible(),
              );
            }
          ),
          actions: <Widget>[
            BasketButton(),
            if (widget.model.isEditable()) IconButton(
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
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomSlider(AppLocalizations.of(context)!.text('oiginal_gravity'), widget.model.og ?? 1, 1, 1.2, 0.01,
                        onFormatted: (double value) {
                          return AppLocalizations.of(context)!.gravityFormat(value);
                        },
                      )
                    ),
                    Expanded(
                      child: CustomSlider(AppLocalizations.of(context)!.text('final_gravity'), widget.model.fg ?? 1, 1, 1.2, 0.01,
                        onFormatted: (double value) {
                          return AppLocalizations.of(context)!.gravityFormat(value);
                        },
                      )
                    ),
                    Expanded(
                      child: CustomSlider(AppLocalizations.of(context)!.text('abv'), widget.model.abv ?? 0, 0, MAX_ABV, 0.1,
                        onFormatted: (double value) {
                          return AppLocalizations.of(context)!.numberFormat(value, pattern: "#0.#'%'");
                        },
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
                              trackShape: const GradientRectSliderTrackShape(darkenInactive: false),
                              thumbColor: Theme.of(context).primaryColor,
                              overlayColor: Theme.of(context).primaryColor.withOpacity(.1),
                              thumbShape: GradientSliderThumbShape(ringColor: Theme.of(context).primaryColor, fillColor: FillColor, selectedValue: 10, max: AppLocalizations.of(context)!.maxColor),
                              valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
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
                        onFormatted: (double value) {
                          return AppLocalizations.of(context)!.numberFormat(value);
                        },
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('${AppLocalizations.of(context)!.text('style')} : ${AppLocalizations.of(context)!.localizedText(widget.model.style!.name)}', overflow: TextOverflow.ellipsis)
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
                              TextSpan(text: '${AppLocalizations.of(context)!.text(DeviceHelper.isSmallScreen(context) ? 'efficiency' : 'pasting_efficiency')} : '),
                              TextSpan(text: AppLocalizations.of(context)!.percentFormat(widget.model.efficiency), style: const TextStyle(fontWeight: FontWeight.bold)),
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
                              TextSpan(text: '${AppLocalizations.of(context)!.text(DeviceHelper.isSmallScreen(context) ? 'volume' : 'mash_volume')} : '),
                              if (widget.model.volume != null) TextSpan(text: AppLocalizations.of(context)!.litterVolumeFormat(widget.model.volume), style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (widget.model.volume == null) const TextSpan(text: 'NC'),
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
                              TextSpan(text: '${AppLocalizations.of(context)!.text(DeviceHelper.isSmallScreen(context) ? 'boiling' : 'boiling_time')} : '),
                              if (widget.model.boil != null) TextSpan(text: AppLocalizations.of(context)!.durationFormat(widget.model.boil), style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (widget.model.boil == null) const TextSpan(text: 'NC'),
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
                      title: Text(AppLocalizations.of(context)!.text('features'),
                          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                    );
                  },
                  body: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
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
              future: widget.model.gethops(),
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
              future: widget.model.getYeasts(),
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
              future: widget.model.getMisc(),
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
            if (widget.model.mash != null && widget.model.mash!.isNotEmpty) Padding(
              padding: const EdgeInsets.all(8.0),
              child: MashDataTable(
                data: widget.model.mash,
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
                      if (widget.model.primaryday != null && widget.model.primarytemp != null) _fermentation(
                        AppLocalizations.of(context)!.text('primary'),
                        widget.model.primaryday!,
                        widget.model.primarytemp!,
                      ),
                      const SizedBox(width: 12),
                      if (widget.model.secondaryday != null && widget.model.secondarytemp != null) _fermentation(
                        AppLocalizations.of(context)!.text('secondary'),
                        widget.model.secondaryday!,
                        widget.model.secondarytemp!,
                      ),
                      const SizedBox(width: 12),
                      if (widget.model.tertiaryday != null && widget.model.tertiarytemp != null) _fermentation(
                        AppLocalizations.of(context)!.text('tertiary'),
                        widget.model.tertiaryday!,
                        widget.model.tertiarytemp!,
                      ),
                    ],
                  )
                ]
              )
            )
          ]
        )),
        SliverToBoxAdapter(child: CarouselContainer(receipt: widget.model.uuid)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
              child: RatingsContainer(widget.model)
             )
           )
        ]
      ),
      floatingActionButton: AnimatedActionButton(
        title: AppLocalizations.of(context)!.text('new_brew'),
        icon: const Icon(Icons.add),
        onPressed: _new,
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

  _edit(ReceiptModel model) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormReceiptPage(model);
    })).then((value) {
      if (value != null) {
        setState(() {
          widget.model = value;
          _key = UniqueKey();
        });
      }
    });
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
                            color: ColorHelper.color(widget.model.ebc) ?? Colors.white,
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
                            clipper: CircleClipper(), //set our custom wave clipper
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
                                if (_rating > 0) Text(_rating.toStringAsPrecision(2), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white)),
                                RatingBar.builder(
                                  initialRating: _rating,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemSize: 18,
                                  itemPadding: EdgeInsets.zero,
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  tapOnlyMode: true,
                                  ignoreGestures: true,
                                  onRatingUpdate: (rating) async {
                                  },
                                ),
                                const SizedBox(height: 3),
                                Text('$_notices ${AppLocalizations.of(context)!.text('reviews')}', style: const TextStyle(color: Colors.white)),
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
