import 'package:flutter/material.dart';

// Internal package
import 'package:bb/models/style_model.dart';
import 'package:bb/utils/abv.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/ibu.dart';
import 'package:bb/utils/srm.dart';
import 'package:bb/widgets/gradient_rect_range_slider_track_shape.dart';
import 'package:bb/widgets/paints/custom_thumb_shape.dart';

// External package

class FilterReceiptAppBar extends StatefulWidget {
  SRM srm;
  IBU ibu;
  ABV abv;
  RangeValues? srm_values;
  List<Fermentation>? selectedFermentations = [];
  List<StyleModel>? styles;
  List<StyleModel>? selectedStyles = [];
  final Function(double start, double end)? onColorChanged;
  final Function(double start, double end)? onIBUChanged;
  final Function(double start, double end)? onAlcoholChanged;
  final Function(Fermentation value)? onFermentationChanged;
  final Function(StyleModel value)? onStyleChanged;
  final Function()? onReset;

  FilterReceiptAppBar({Key? key,
    required this.srm,
    required this.ibu,
    required this.abv,
    this.selectedFermentations,
    this.styles,
    this.selectedStyles,
    this.onColorChanged,
    this.onIBUChanged,
    this.onAlcoholChanged,
    this.onFermentationChanged,
    this.onStyleChanged,
    this.onReset,
  }) : super(key: key) {
    if (selectedFermentations == null) selectedFermentations = [];
    if (styles == null) styles = [];
    if (selectedStyles == null) selectedStyles = [];
    if (srm_values == null) srm_values = RangeValues(srm.start ?? 0, srm.end ?? SRM_COLORS.length.toDouble());
  }

  _FilterReceiptAppBarState createState() => new _FilterReceiptAppBarState();
}

class _FilterReceiptAppBarState extends State<FilterReceiptAppBar> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool changed = false;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(
      length: 4,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
        automaticallyImplyLeading: false,
        expandedHeight: MediaQuery.of(context).size.height / 2.7,
        backgroundColor: FillColor,
        title: TabBar(
          controller: _tabController,
          indicator: ShapeDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0) ),
          ),
          tabs: [
            Tab(icon: Icon(Icons.tune, color: Theme.of(context).primaryColor), iconMargin: EdgeInsets.zero, child: Text('Saveur', style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor))),
            Tab(icon: Icon(Icons.palette_outlined, color: Theme.of(context).primaryColor), iconMargin: EdgeInsets.zero, child: Text('Couleur', style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor))),
            Tab(icon: Icon(Icons.bubble_chart_outlined, color: Theme.of(context).primaryColor), iconMargin: EdgeInsets.zero, child: Text('Type', style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor))),
            Tab(icon: Icon(Icons.style_outlined, color: Theme.of(context).primaryColor), iconMargin: EdgeInsets.zero, child: Text('Style', style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor))),
          ],
        ),
        flexibleSpace: FlexibleSpaceBar(
          background: TabBarView(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              _flavor(),
              _color(),
              _fermentation(),
              _styles()
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size(double.infinity, kToolbarHeight),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: Icon(Icons.clear, size: 12),
                label: Text(AppLocalizations.of(context)!.text('erase_all')),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0) ),
                  textStyle: const TextStyle(fontSize: 12),
                ),
                onPressed: changed ? () {
                  setState(() {
                    changed = false;
                  });
                  widget.onReset?.call();
                } : null
              )
            ],
          )
        )
    );
  }

  Widget _flavor() {
    return Container(
      padding: EdgeInsets.only(left: 12, right: 12, top: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(AppLocalizations.of(context)!.text('ibu'), style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0)),
          Row(
            children: [
              SizedBox(width: 25, child: Text((widget.ibu.start ?? widget.ibu.min).round().toString(), style: TextStyle(fontSize: 12))),
              Expanded(
                child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 2,
                      thumbColor: Theme.of(context).primaryColor,
                      activeTrackColor: Theme.of(context).primaryColor,
                      inactiveTrackColor: Theme.of(context).primaryColor.withOpacity(.4),
                      overlayColor: Theme.of(context).primaryColor.withOpacity(.1),
                      rangeThumbShape: CustomThumbShape(ringColor: Theme.of(context).primaryColor, fillColor: FillColor),
                      showValueIndicator: ShowValueIndicator.always,
                      valueIndicatorTextStyle: TextStyle(fontSize: 12)
                    ),
                    child: RangeSlider(
                      min: widget.ibu.min,
                      max: widget.ibu.max,
                      values: RangeValues(widget.ibu.start ?? widget.ibu.min, widget.ibu.end ?? widget.ibu.max),
                      labels: RangeLabels(IBU.label(widget.ibu.start ?? widget.ibu.min), IBU.label(widget.ibu.end ?? widget.ibu.max)),
                      onChanged: (values) {
                        setState(() {
                          changed = true;
                          widget.ibu.start = values.start;
                          widget.ibu.end = values.end;
                        });
                        widget.onIBUChanged?.call(values.start, values.end);
                      },
                    )
                  )
              ),
              SizedBox(width: 25, child: Text((widget.ibu.end ?? widget.ibu.max).round().toString(), style: TextStyle(fontSize: 12))),
            ]
          ),
          Text(AppLocalizations.of(context)!.text('abv'), style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0)),
          Row(
            children: [
              SizedBox(width: 25, child: Text('${(widget.abv.start ?? widget.abv.min).toStringAsPrecision(2)}°', softWrap: false, style: TextStyle(fontSize: 12))),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2,
                    thumbColor: Theme.of(context).primaryColor,
                    activeTrackColor: Theme.of(context).primaryColor,
                    inactiveTrackColor: Theme.of(context).primaryColor.withOpacity(.4),
                    overlayColor: Theme.of(context).primaryColor.withOpacity(.1),
                    rangeThumbShape: CustomThumbShape(ringColor: Theme.of(context).primaryColor, fillColor: FillColor),
                    // showValueIndicator: ShowValueIndicator.always
                  ),
                  child: RangeSlider(
                    min: widget.abv.min,
                    max: widget.abv.max,
                    values: RangeValues(widget.abv.start ?? widget.abv.min, widget.abv.end ?? widget.abv.max),
                    // labels: RangeLabels((_startAlcohol ?? _minAlcohol).toStringAsPrecision(2), (_endAlcohol ?? _maxAlcohol).toStringAsPrecision(2)),
                    onChanged: (values) {
                      setState(() {
                        changed = true;
                        widget.abv.start = values.start;
                        widget.abv.end = values.end;
                      });
                      widget.onAlcoholChanged?.call(values.start, values.end);
                    },
                    )
                )
              ),
              SizedBox(width: 25, child: Text('${(widget.abv.end ?? widget.abv.max).toStringAsPrecision(2)}°', softWrap: false, style: TextStyle(fontSize: 12))),
            ]
          ),
        ]
      )
    );
  }

  Widget _color() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(AppLocalizations.of(context)!.text('srm'), style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0)),
          Row(
            children: [
              SizedBox(width: 20, child: Text('${widget.srm.start != null ?  widget.srm.start!.round() : 0}', softWrap: false, style: TextStyle(fontSize: 12))),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 5,
                    rangeTrackShape: GradientRectRangeSliderTrackShape(),
                    thumbColor: Theme.of(context).primaryColor,
                    overlayColor: Theme.of(context).primaryColor.withOpacity(.1),
                    rangeThumbShape: CustomThumbShape(ringColor: Theme.of(context).primaryColor, fillColor: FillColor),
                  ),
                  child: RangeSlider(
                    onChanged: (values) {
                      setState(() {
                        changed = true;
                        widget.srm.start = values.start;
                        widget.srm.end = values.end;
                      });
                      widget.onColorChanged?.call(values.start, values.end);
                    },
                    values: RangeValues(widget.srm.start ?? 0, widget.srm.end ?? SRM_COLORS.length.toDouble()),
                    min: 0,
                    max: SRM_COLORS.length.toDouble(),
                    divisions: SRM_COLORS.length
                  )
                )
              ),
              SizedBox(width: 20, child: Text('${widget.srm.end != null ? widget.srm.end!.round() : SRM_COLORS.length}', softWrap: false, style: TextStyle(fontSize: 12))),
            ]
          )
        ]
      )
    );
  }

  Widget _fermentation() {
    return Container(
      padding: EdgeInsets.only(left: 12, right: 12, top: 52, bottom: 33),
      child: Wrap(
        spacing: 2.0,
        runSpacing: 4.0,
        direction: Axis.vertical,
        children: Fermentation.values.map((e) {
          return FilterChip(
            selected: widget.selectedFermentations!.contains(e),
            padding: EdgeInsets.zero,
            label: Text(
              AppLocalizations.of(context)!.text(e.toString().toLowerCase()),
              style: TextStyle(
                fontSize: 12.0,
              ),
            ),
            selectedColor: BlendColor,
            backgroundColor: FillColor,
            shape: StadiumBorder(side: BorderSide(color: Colors.black12)),
            onSelected: (value) {
              setState(() {
                changed = true;
              });
              widget.onFermentationChanged?.call(e);
            }
          );
        }).toList()
      )
    );
  }

  Widget _styles() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(left: 12, right: 12, top: 52, bottom: 33),
      child: Wrap(
        spacing: 2.0,
        runSpacing: 4.0,
        direction: Axis.vertical,
        children: widget.styles!.map((e) {
          return FilterChip(
            selected: widget.selectedStyles!.contains(e),
            padding: EdgeInsets.zero,
            label: Text(
              e.title ?? '',
              style: TextStyle(
                fontSize: 12.0,
              ),
            ),
            selectedColor: BlendColor,
            backgroundColor: FillColor,
            shape: StadiumBorder(side: BorderSide(color: Colors.black12)),
            onSelected: (value) {
              setState(() {
                changed = true;
              });
              widget.onStyleChanged?.call(e);
            }
          );
        }).toList()
      )
    );
  }
}

