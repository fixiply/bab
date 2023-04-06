import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/basket_page.dart';
import 'package:bb/controller/forms/form_receipt_page.dart';
import 'package:bb/controller/tables/fermentables_data_table.dart';
import 'package:bb/controller/tables/hops_data_table.dart';
import 'package:bb/controller/tables/mash_data_table.dart';
import 'package:bb/controller/tables/miscellaneous_data_table.dart';
import 'package:bb/controller/tables/yeasts_data_table.dart';
import 'package:bb/helpers/device_helper.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:bb/models/style_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/basket_notifier.dart';
import 'package:bb/utils/color_units.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/utils/edition_notifier.dart';
import 'package:bb/widgets/containers/carousel_container.dart';
import 'package:bb/widgets/custom_menu_button.dart';
import 'package:bb/widgets/paints/bezier_clipper.dart';
import 'package:bb/widgets/paints/circle_clipper.dart';

// External package
import 'package:badges/badges.dart' as badge;
import 'package:flutter_markdown/flutter_markdown.dart';
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
  StyleModel? _style;
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
                        color: ColorUnits.color(widget.model.ebc) ?? SRM_COLORS[0],
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
          if (currentUser != null && (currentUser!.isAdmin() || widget.model.creator == currentUser!.uuid))
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
      if (_style != null) SliverToBoxAdapter(
        child: Padding( 
          padding: EdgeInsets.all(8.0),
          child: RichText(
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: [
                TextSpan(text: '${AppLocalizations.of(context)!.text('style')}${AppLocalizations.of(context)!.colon}  ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                TextSpan(text: _labelStyle(), style: TextStyle(fontSize: 20)),
              ]
            )
          )
        )
      ),
      if (widget.model.text != null && widget.model.text!.isNotEmpty) SliverToBoxAdapter(
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
      SliverList(delegate: SliverChildListDelegate(
        [
          if (widget.model.fermentables != null && widget.model.fermentables!.isNotEmpty) FermentablesDataTable(
              data: widget.model.fermentables,
              title: Text(AppLocalizations.of(context)!.text('fermentables'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0)),
              allowEditing: false, allowSorting: false, showCheckboxColumn: false
          ),
          if (widget.model.hops != null && widget.model.hops!.isNotEmpty) HopsDataTable(
              data: widget.model.hops,
              title: Text(AppLocalizations.of(context)!.text('hops'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0)),
              allowEditing: false, allowSorting: false, showCheckboxColumn: false
          ),
          if (widget.model.yeasts != null && widget.model.yeasts!.isNotEmpty) YeastsDataTable(
              data: widget.model.yeasts,
              title: Text(AppLocalizations.of(context)!.text('yeasts'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0)),
              allowEditing: false, allowSorting: false, showCheckboxColumn: false
          ),
          if (widget.model.miscellaneous != null && widget.model.miscellaneous!.isNotEmpty) MiscellaneousDataTable(
              data: widget.model.miscellaneous,
              title: Text(AppLocalizations.of(context)!.text('miscellaneous'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0)),
              allowEditing: false, allowSorting: false, showCheckboxColumn: false
          ),
          if (widget.model.mash != null && widget.model.mash!.isNotEmpty) MashDataTable(
              data: widget.model.mash,
              title: Text(AppLocalizations.of(context)!.text('mash'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0)),
              allowEditing: false, allowSorting: false, showCheckboxColumn: false
          )
        ]
      )),
      SliverToBoxAdapter(child: CarouselContainer(receipt: widget.model.uuid)),
    ]));
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
    _fetch();
  }

  _fetch() async {
    if (widget.model.style != null) {
      StyleModel? style = await Database().getStyle(widget.model.style!);
      setState(() {
        _style = style;
      });
    }
  }

  _edit(ReceiptModel model) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormReceiptPage(model);
    }));
  }

  String _labelStyle() {
    if (_style != null) {
      return AppLocalizations.of(context)!.localizedText(_style!.name);
    }
    return '';
  }
}
