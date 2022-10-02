import 'package:flutter/material.dart';

// Internal package
import 'package:bb/utils/abv.dart';
import 'package:bb/utils/ibu.dart';
import 'package:bb/controller/basket_page.dart';
import 'package:bb/controller/forms/form_style_page.dart';
import 'package:bb/models/style_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/basket_notifier.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/edition_notifier.dart';
import 'package:bb/widgets/gradient_rect_range_slider_track_shape.dart';
import 'package:bb/widgets/paints/custom_thumb_shape.dart';

// External package
import 'package:badges/badges.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

class StylePage extends StatefulWidget {
  final StyleModel model;
  StylePage(this.model);
  _StylePageState createState() => new _StylePageState();
}

class _StylePageState extends State<StylePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  // Edition mode
  bool _editable = false;
  bool _expanded = true;
  int _baskets = 0;

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
        title: Text(widget.model.title!),
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        actions: <Widget>[
          Badge(
            position: BadgePosition.topEnd(top: 0, end: 3),
            animationDuration: Duration(milliseconds: 300),
            animationType: BadgeAnimationType.slide,
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
          if (_editable && currentUser != null && currentUser!.isEditor())
            IconButton(
              icon: Icon(Icons.edit_note),
              onPressed: () {
                _edit(widget.model);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)!.text('ibu'), style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0)),
                  Row(
                    children: [
                      SizedBox(width: 25, child: Text((widget.model.min_ibu ?? 0).round().toString(), style: TextStyle(fontSize: 12))),
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
                            min: 0,
                            max: MAX_IBU,
                            values: RangeValues(widget.model.min_ibu ?? 0, widget.model.max_ibu ?? MAX_IBU),
                            labels: RangeLabels(IBU.label(widget.model.min_ibu ?? 0), IBU.label(widget.model.max_ibu ?? MAX_IBU)),
                            onChanged: (values) {
                            },
                          )
                        )
                      ),
                      SizedBox(width: 25, child: Text((widget.model.max_ibu ?? MAX_IBU).round().toString(), style: TextStyle(fontSize: 12))),
                    ]
                  ),
                  Text(AppLocalizations.of(context)!.text('alcohol'), style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0)),
                  Row(
                    children: [
                      SizedBox(width: 25, child: Text('${ widget.model.min_abv != null ?  widget.model.min_abv!.toStringAsPrecision(2) : 0}°', softWrap: false, style: TextStyle(fontSize: 12))),
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
                            min: 0,
                            max: MAX_ABV,
                            values: RangeValues(widget.model.min_abv ?? 0, widget.model.max_abv ?? MAX_ABV),
                            // labels: RangeLabels((_startAlcohol ?? _minAlcohol).toStringAsPrecision(2), (_endAlcohol ?? _maxAlcohol).toStringAsPrecision(2)),
                            onChanged: (values) {
                            },
                          )
                        )
                      ),
                      SizedBox(width: 25, child: Text('${(widget.model.max_abv ?? MAX_ABV).toStringAsPrecision(2)}°', softWrap: false, style: TextStyle(fontSize: 12))),
                    ]
                  ),
                  Text(AppLocalizations.of(context)!.text('srm'), style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0)),
                  Row(
                    children: [
                      SizedBox(width: 20, child: Text('${widget.model.min_ebc != null ?  widget.model.min_ebc!.round() : 0}', softWrap: false, style: TextStyle(fontSize: 12))),
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
                            },
                            values: RangeValues(widget.model.min_ebc ?? 0, widget.model.max_ebc ?? SRM_COLORS.length.toDouble()),
                            min: 0,
                            max: SRM_COLORS.length.toDouble(),
                            divisions: SRM_COLORS.length
                          )
                        )
                      ),
                      SizedBox(width: 20, child: Text('${widget.model.max_ebc != null ? widget.model.max_ebc!.round() : SRM_COLORS.length}', softWrap: false, style: TextStyle(fontSize: 12))),
                    ]
                  )
                ]
              )
            ),
            ExpansionPanelList(
              elevation: 1,
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
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                    );
                  },
                  body: Container(
                      padding: EdgeInsets.only(bottom: 12, left: 12, right: 12),
                      child: MarkdownBody(
                        data: widget.model.text!,
                        softLineBreak: true,
                        styleSheet:
                        MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(textScaleFactor: 1.2, textAlign: WrapAlignment.start),
                      )
                  ),
                )
              ]
            )
          ]
        )
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

  _edit(StyleModel model) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormStylePage(model);
    }));
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

