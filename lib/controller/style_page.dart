import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/forms/form_style_page.dart';
import 'package:bab/helpers/color_helper.dart';
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/models/style_model.dart';
import 'package:bab/utils/abv.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/utils/ibu.dart';
import 'package:bab/widgets/basket_button.dart';
import 'package:bab/widgets/custom_menu_anchor.dart';
import 'package:bab/widgets/custom_menu_button.dart';
import 'package:bab/widgets/paints/gradient_range_slider_thumb_shape.dart';
import 'package:bab/widgets/paints/gradient_range_slider_track_shape.dart';

// External package
import 'package:flutter_markdown/flutter_markdown.dart';

class StylePage extends StatefulWidget {
  final StyleModel model;
  StylePage(this.model);

  @override
  _StylePageState createState() => _StylePageState();
}

class _StylePageState extends State<StylePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  // Edition mode
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: FillColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.localizedText(widget.model.name)),
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: DeviceHelper.isLargeScreen(context) ? const Icon(Icons.close) : const BackButtonIcon(),
          onPressed:() async {
            Navigator.pop(context);
          }
        ),
        actions: <Widget>[
          BasketButton(),
          if (widget.model.isEditable() )
            IconButton(
              icon: const Icon(Icons.edit_note),
              onPressed: () {
                _edit(widget.model);
              },
            ),
          CustomMenuAnchor(
            context: context,
            publish: false,
            filtered: false,
            archived: false,
            measures: true,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)!.text('ibu'), style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0)),
                  Row(
                    children: [
                      SizedBox(width: 30, child: Text((widget.model.ibumin ?? 0).round().toString(), style: const TextStyle(fontSize: 12))),
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
                            min: 0,
                            max: MAX_IBU,
                            values: RangeValues(widget.model.ibumin ?? 0, widget.model.ibumax ?? MAX_IBU),
                            labels: RangeLabels(IBU.label(widget.model.ibumin ?? 0), IBU.label(widget.model.ibumax ?? MAX_IBU)),
                            onChanged: (values) {
                            },
                          )
                        )
                      ),
                      SizedBox(width: 30, child: Text((widget.model.ibumax ?? MAX_IBU).round().toString(), style: const TextStyle(fontSize: 12))),
                    ]
                  ),
                  Text(AppLocalizations.of(context)!.text('abv'), style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0)),
                  Row(
                    children: [
                      SizedBox(width: 30, child: Text('${ widget.model.abvmin != null ?  widget.model.abvmin!.toStringAsPrecision(2) : 0}%', softWrap: false, style: const TextStyle(fontSize: 12))),
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
                            min: 0,
                            max: MAX_ABV,
                            values: RangeValues(widget.model.abvmin ?? 0, widget.model.abvmax ?? MAX_ABV),
                            // labels: RangeLabels((_startAlcohol ?? _minAlcohol).toStringAsPrecision(2), (_endAlcohol ?? _maxAlcohol).toStringAsPrecision(2)),
                            onChanged: (values) {
                            },
                          )
                        )
                      ),
                      SizedBox(width: 30, child: Text('${(widget.model.abvmax ?? MAX_ABV).toStringAsPrecision(2)}%', softWrap: false, style: const TextStyle(fontSize: 12))),
                    ]
                  ),
                  Text('${AppLocalizations.of(context)!.colorUnit} - ${AppLocalizations.of(context)!.text('color')}', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0)),
                  Row(
                    children: [
                      SizedBox(width: 30, child: Text(AppLocalizations.of(context)!.colorFormat(widget.model.ebcmin ?? 0) ?? '', softWrap: false, style: const TextStyle(fontSize: 12))),
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
                            onChanged: (values) {  },
                            values: RangeValues(
                              ColorHelper.toSRM(widget.model.ebcmin).toDouble(),
                              widget.model.ebcmax != null ? ColorHelper.toSRM(widget.model.ebcmax).toDouble() : AppLocalizations.of(context)!.maxColor.toDouble()
                            ),
                            min: 0,
                            max: AppLocalizations.of(context)!.maxColor.toDouble(),
                            divisions: AppLocalizations.of(context)!.maxColor
                          )
                        )
                      ),
                      SizedBox(width: 30, child: Text(AppLocalizations.of(context)!.colorFormat(widget.model.ebcmax ?? AppLocalizations.of(context)!.maxColor) ?? '', softWrap: false, style: const TextStyle(fontSize: 12))),
                    ]
                  )
                ]
              )
            ),
            ExpansionPanelList(
              elevation: 1,
              expandedHeaderPadding: EdgeInsets.zero,
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  _expanded = !isExpanded;
                });
              },
              children: [
                if (widget.model.overallimpression != null) ExpansionPanel(
                  isExpanded: _expanded,
                  canTapOnHeader: true,
                  headerBuilder: (context, isExpanded) {
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                      title: Text(AppLocalizations.of(context)!.text('overall_impression'),
                          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                    );
                  },
                  body: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
                    child: MarkdownBody(
                      data: AppLocalizations.of(context)!.localizedText(widget.model.overallimpression),
                      softLineBreak: true,
                      styleSheet:
                      MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(textScaleFactor: 1.2, textAlign: WrapAlignment.start),
                    )
                  ),
                ),
                if (widget.model.aroma != null) ExpansionPanel(
                  isExpanded: _expanded,
                  canTapOnHeader: true,
                  headerBuilder: (context, isExpanded) {
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                      title: Text(AppLocalizations.of(context)!.text('aroma'),
                          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                    );
                  },
                  body: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
                    child: MarkdownBody(
                      data: AppLocalizations.of(context)!.localizedText(widget.model.aroma),
                      softLineBreak: true,
                      styleSheet:
                      MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(textScaleFactor: 1.2, textAlign: WrapAlignment.start),
                    )
                  ),
                ),
                if (widget.model.flavor != null) ExpansionPanel(
                  isExpanded: _expanded,
                  canTapOnHeader: true,
                  headerBuilder: (context, isExpanded) {
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                      title: Text(AppLocalizations.of(context)!.text('flavor'),
                          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                    );
                  },
                  body: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
                    child: MarkdownBody(
                      data: AppLocalizations.of(context)!.localizedText(widget.model.flavor),
                      softLineBreak: true,
                      styleSheet:
                      MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(textScaleFactor: 1.2, textAlign: WrapAlignment.start),
                    )
                  ),
                ),
                if (widget.model.mouthfeel != null) ExpansionPanel(
                  isExpanded: _expanded,
                  canTapOnHeader: true,
                  headerBuilder: (context, isExpanded) {
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                      title: Text(AppLocalizations.of(context)!.text('mouthfeel'),
                          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                    );
                  },
                  body: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
                    child: MarkdownBody(
                      data: AppLocalizations.of(context)!.localizedText(widget.model.mouthfeel),
                      softLineBreak: true,
                      styleSheet:
                      MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(textScaleFactor: 1.2, textAlign: WrapAlignment.start),
                      )
                  ),
                ),
                if (widget.model.comments != null) ExpansionPanel(
                  isExpanded: _expanded,
                  canTapOnHeader: true,
                  headerBuilder: (context, isExpanded) {
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                      title: Text(AppLocalizations.of(context)!.text('comments'),
                          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                    );
                  },
                  body: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
                    child: MarkdownBody(
                      data: AppLocalizations.of(context)!.localizedText(widget.model.comments),
                      softLineBreak: true,
                      styleSheet:
                      MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(textScaleFactor: 1.2, textAlign: WrapAlignment.start),
                    )
                  ),
                ),
              ]
            )
          ]
        )
      )
    );
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
          duration: const Duration(seconds: 10)
        )
    );
  }
}

