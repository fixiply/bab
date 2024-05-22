import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/forms/form_product_page.dart';
import 'package:bab/helpers/device_helper.dart';
import 'package:bab/models/product_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/utils/constants.dart';
import 'package:bab/widgets/basket_button.dart';
import 'package:bab/widgets/containers/image_container.dart';
import 'package:bab/widgets/containers/ratings_container.dart';
import 'package:bab/widgets/modal_bottom_sheet.dart';
import 'package:bab/widgets/paints/bezier_clipper.dart';
import 'package:bab/widgets/paints/circle_clipper.dart';

// External package
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProductPage extends StatefulWidget {
  final ProductModel model;
  ProductPage(this.model);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _controller,
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 250.0,
            foregroundColor: Colors.white,
            backgroundColor: Theme.of(context).primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 140),
              title: Text(AppLocalizations.of(context)!.localizedText(widget.model.title)),
              background: Stack(
                children: [
                  Opacity( //semi red clippath with more height and with 0.5 opacity
                    opacity: 0.5,
                    child: ClipPath(
                      clipper: BezierClipper(), //set our custom wave clipper
                      child:Container(
                        color: Colors.black,
                        height: 200,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 30),
                        child: ImageContainer(widget.model.image, width: null, height: null, color: Colors.transparent),
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
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (widget.model.rating > 0) Text(widget.model.rating.toStringAsPrecision(2), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white)),
                                  RatingBar.builder(
                                    initialRating: widget.model.rating,
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
                                  Text('${widget.model.notice} ${AppLocalizations.of(context)!.text('reviews')}', style: const TextStyle(color: Colors.white)),
                                  const SizedBox(height: 10),
                                  Stack(
                                    children: [
                                      Image.asset('assets/images/sale.png', width: 80, color: Colors.black38),
                                      Positioned(
                                          left: 22,
                                          top: 9,
                                          child: Text(AppLocalizations.of(context)!.currencyFormat(widget.model.price) ?? '', style: const TextStyle(fontSize: 16, color: Colors.white))
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ]
                        ),
                      )
                    ]
                  )
                ]
              ),
            ),
            actions: <Widget> [
              BasketButton(),
              if (currentUser != null && currentUser!.isAdmin()) IconButton(
                icon: const Icon(Icons.edit_note),
                onPressed: () {
                  _edit(widget.model);
                },
              ),
            ],
          ),
          if (widget.model.text!.isNotEmpty) SliverToBoxAdapter(
            child: ExpansionTile(
                initiallyExpanded: true,
                title: Text(AppLocalizations.of(context)!.text('features'), style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                children: <Widget>[
                  Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
                      child: MarkdownBody(data: widget.model.text!, softLineBreak: true,
                        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                            .copyWith(textScaleFactor: 1.2, textAlign: WrapAlignment.start),)
                  )
                ]
            ),
          ),
          SliverToBoxAdapter(
            child: RatingsContainer(widget.model)
          )
        ]
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(18)),
          child: Text(AppLocalizations.of(context)!.text('buy_now')),
          onPressed: () async {
            ModalBottomSheet.showAddToCart(context, widget.model);
          },
        ),
      ),
    );
  }

  _edit(ProductModel model) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormProductPage(model);
    }));
  }
}