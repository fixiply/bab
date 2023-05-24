import 'package:flutter/material.dart';

// Internal package
import 'package:bb/utils/category.dart';
import 'package:bb/utils/abv.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/ibu.dart';
import 'package:bb/helpers/color_helper.dart';
import 'package:bb/widgets/paints/gradient_range_slider_track_shape.dart';
import 'package:bb/widgets/paints/gradient_range_slider_thumb_shape.dart';

// External package

class FilterStyleAppBar extends StatefulWidget {
  ColorHelper cu;
  IBU ibu;
  ABV abv;
  RangeValues? srm_values;
  List<Fermentation>? selectedFermentations = [];
  List<Category>? categories;
  List<Category>? selectedCategories = [];
  final Function(double start, double end)? onColorChanged;
  final Function(double start, double end)? onIBUChanged;
  final Function(double start, double end)? onAlcoholChanged;
  final Function(Fermentation value)? onFermentationChanged;
  final Function(Category value)? onCategoryChanged;
  final Function()? onReset;

  FilterStyleAppBar({Key? key,
    required this.cu,
    required this.ibu,
    required this.abv,
    this.selectedFermentations,
    this.categories,
    this.selectedCategories,
    this.onColorChanged,
    this.onIBUChanged,
    this.onAlcoholChanged,
    this.onFermentationChanged,
    this.onCategoryChanged,
    this.onReset,
  }) : super(key: key) {
    selectedFermentations ??= [];
    srm_values ??= RangeValues(cu.start ?? 0, cu.end ?? SRM_COLORS.length.toDouble());
  }

  @override
  _FilterStyleAppBarState createState() => _FilterStyleAppBarState();
}

class _FilterStyleAppBarState extends State<FilterStyleAppBar> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool changed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
          tabs: [
            Tab(icon: Icon(Icons.tune, color: Theme.of(context).primaryColor), iconMargin: EdgeInsets.zero, child: Text(AppLocalizations.of(context)!.text('flavor'), style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor))),
            Tab(icon: Icon(Icons.palette_outlined, color: Theme.of(context).primaryColor), iconMargin: EdgeInsets.zero, child: Text(AppLocalizations.of(context)!.text('color'), style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor))),
            Tab(icon: Icon(Icons.bubble_chart_outlined, color: Theme.of(context).primaryColor), iconMargin: EdgeInsets.zero, child: Text(AppLocalizations.of(context)!.text('type'), style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor))),
            Tab(icon: Icon(Icons.style_outlined, color: Theme.of(context).primaryColor), iconMargin: EdgeInsets.zero, child: Text(AppLocalizations.of(context)!.text('style'), style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor))),
          ],
        ),
        flexibleSpace: FlexibleSpaceBar(
          background: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
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
          child: Container(
            padding: const EdgeInsets.all(4.0),
            alignment: Alignment.centerRight,
            child:  FilledButton.tonal(
              style: FilledButton.styleFrom(foregroundColor: Colors.black, backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  const Icon(Icons.clear, size: 12),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.text('erase_all'), overflow: TextOverflow.visible, style: const TextStyle(fontSize: 13)),
                ],
              ),
              onPressed: changed ? () {
                setState(() {
                  changed = false;
                });
                widget.onReset?.call();
              } : null
            ),
          )
        )
    );
  }

  Widget _flavor() {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(AppLocalizations.of(context)!.text('ibu'), style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0)),
          Row(
            children: [
              SizedBox(width: 30, child: Text((widget.ibu.start ?? widget.ibu.min).round().toString(), style: const TextStyle(fontSize: 12))),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                      trackHeight: 2,
                      thumbColor: Theme.of(context).primaryColor,
                      activeTrackColor: Theme.of(context).primaryColor,
                      inactiveTrackColor: Theme.of(context).primaryColor.withOpacity(.4),
                      overlayColor: Theme.of(context).primaryColor.withOpacity(.1),
                      rangeThumbShape: CustomRangeSliderThumbShape(ringColor: Theme.of(context).primaryColor, fillColor: FillColor),
                      showValueIndicator: ShowValueIndicator.always,
                      valueIndicatorTextStyle: const TextStyle(fontSize: 12)
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
              SizedBox(width: 30, child: Text((widget.ibu.end ?? widget.ibu.max).round().toString(), style: const TextStyle(fontSize: 12))),
            ]
          ),
          Text(AppLocalizations.of(context)!.text('abv'), style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0)),
          Row(
            children: [
              SizedBox(width: 30, child: Text('${(widget.abv.start ?? widget.abv.min).toStringAsPrecision(2)}%', softWrap: false, style: const TextStyle(fontSize: 12))),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2,
                    thumbColor: Theme.of(context).primaryColor,
                    activeTrackColor: Theme.of(context).primaryColor,
                    inactiveTrackColor: Theme.of(context).primaryColor.withOpacity(.4),
                    overlayColor: Theme.of(context).primaryColor.withOpacity(.1),
                    rangeThumbShape: CustomRangeSliderThumbShape(ringColor: Theme.of(context).primaryColor, fillColor: FillColor),
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
              SizedBox(width: 30, child: Text('${(widget.abv.end ?? widget.abv.max).toStringAsPrecision(2)}%', softWrap: false, style: const TextStyle(fontSize: 12))),
            ]
          ),
        ]
      )
    );
  }

  Widget _color() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${AppLocalizations.of(context)!.colorUnit} - ${AppLocalizations.of(context)!.text('color')}', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0)),
          Row(
            children: [
              SizedBox(width: 20, child: Text(AppLocalizations.of(context)!.numberFormat(widget.cu.start ?? 0) ?? '', softWrap: false, style: const TextStyle(fontSize: 12))),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 5,
                    rangeTrackShape: GradientRangeSliderTrackShape(),
                    thumbColor: Theme.of(context).primaryColor,
                    overlayColor: Theme.of(context).primaryColor.withOpacity(.1),
                    rangeThumbShape: CustomRangeSliderThumbShape(ringColor: Theme.of(context).primaryColor, fillColor: FillColor),
                  ),
                  child: RangeSlider(
                    onChanged: (values) {
                      setState(() {
                        changed = true;
                        widget.cu.start = values.start;
                        widget.cu.end = values.end;
                      });
                      widget.onColorChanged?.call(values.start, values.end);
                    },
                    values: RangeValues(widget.cu.start ?? 0, widget.cu.end ?? AppLocalizations.of(context)!.maxColor.toDouble()),
                    min: 0,
                    max: AppLocalizations.of(context)!.maxColor.toDouble(),
                    divisions: AppLocalizations.of(context)!.maxColor
                  )
                )
              ),
              SizedBox(width: 20, child: Text(AppLocalizations.of(context)!.numberFormat(widget.cu.end ?? AppLocalizations.of(context)!.maxColor) ?? '', softWrap: false, style: const TextStyle(fontSize: 12))),
            ]
          )
        ]
      )
    );
  }

  Widget _fermentation() {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 52, bottom: 33),
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
              style: const TextStyle(
                fontSize: 12.0,
              ),
            ),
            selectedColor: BlendColor,
            backgroundColor: FillColor,
            shape: const StadiumBorder(side: BorderSide(color: Colors.black12)),
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
      padding: const EdgeInsets.only(left: 12, right: 12, top: 52, bottom: 33),
      child: Wrap(
        spacing: 2.0,
        runSpacing: 4.0,
        direction: Axis.vertical,
        children: widget.categories!.map((e) {
          return FilterChip(
            selected: widget.selectedCategories!.contains(e),
            padding: EdgeInsets.zero,
            label: Text(
              e.localizedName(AppLocalizations.of(context)!.locale) ?? '',
              style: const TextStyle(
                fontSize: 12.0,
              ),
            ),
            selectedColor: BlendColor,
            backgroundColor: FillColor,
            shape: const StadiumBorder(side: BorderSide(color: Colors.black12)),
            onSelected: (value) {
              setState(() {
                changed = true;
              });
              widget.onCategoryChanged?.call(e);
            }
          );
        }).toList()
      )
    );
  }
}

