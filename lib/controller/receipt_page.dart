import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/basket_page.dart';
import 'package:bb/controller/forms/form_receipt_page.dart';
import 'package:bb/models/receipt_model.dart';
import 'package:bb/models/style_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/utils/edition_notifier.dart';
import 'package:bb/widgets/containers/beers_carousel.dart';
import 'package:bb/widgets/paints/bezier_clipper.dart';
import 'package:bb/widgets/paints/circle_clipper.dart';
import 'package:bb/widgets/paints/wave_clipper.dart';

// External package
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

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: <Widget>[
      SliverAppBar(
        pinned: true,
        expandedHeight: 250.0,
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
        flexibleSpace: FlexibleSpaceBar(
          titlePadding: EdgeInsets.only(left: 170),
          title: Text(widget.model.title!),
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
                      child: Image.asset('assets/images/beer3.png', color: SRM[widget.model.getSRM()]
                        // fit: BoxFit.fill,
                        // colorBlendMode: BlendMode.modulate
                        ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 30),
                      child: Image.asset('assets/images/beer2.png'),
                    ),
                  ]
                ),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipPath(
                        clipper: CircleClipper(radius: _style != null && _style!.title!.length > 8 ? 80 : 65), //set our custom wave clipper
                        child: Container(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (_style != null) FittedBox(
                              child: Text(_style!.title!, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white))
                          ),
                          if (widget.model.ibu != null) Text('IBU: ${widget.model.ibu}', style: TextStyle(fontSize: 18, color: Colors.white)),
                          if (widget.model.alcohol != null) Text('${widget.model.alcohol}°', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ]
                  )
                )
              ]
            )
          ]),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return BasketPage();
              }));
            },
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
      if (widget.model.text!.isNotEmpty)
        SliverToBoxAdapter(
            child: ExpansionPanelList(
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
                  )),
              )
            ])),
      SliverToBoxAdapter(child: BeersCarousel(receipt: widget.model.uuid)),
    ]));
  }

  _initialize() async {
    final provider = Provider.of<EditionNotifier>(context, listen: false);
    _editable = provider.editable;
    _fetch();
  }

  _fetch() async {
    StyleModel? style = await Database().getStyle(widget.model.style!);
    setState(() {
      _style = style;
    });
  }

  _edit(ReceiptModel model) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormReceiptPage(model);
    }));
  }
}
