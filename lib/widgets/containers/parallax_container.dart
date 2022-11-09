import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/product_page.dart';
import 'package:bb/models/product_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/widgets/containers/abstract_container.dart';
import 'package:bb/widgets/custom_image.dart';

// External package
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:parallax_animation/parallax_area.dart';

class ParallaxContainer extends AbstractContainer {
  ParallaxContainer({String? company, String? receipt, int? product}) : super(
      company: company,
      receipt: receipt,
      product: product
  );

  _ParallaxContainerState createState() => new _ParallaxContainerState();
}

class _ParallaxContainerState extends AbstractContainerState {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      color: Colors.white,
      child: FutureBuilder<List<ProductModel>>(
        future: products,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ParallaxArea(
              child: ListView.builder(
                shrinkWrap: true,
                // physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data!.length,
                itemExtent: 280,
                itemBuilder: (context, index) {
                  ProductModel model = snapshot.data![index];
                  double rating = ratings.containsKey(model.uuid) ? ratings[model.uuid]! : 0;
                  int notice = notices.containsKey(model.uuid) ? notices[model.uuid]! : 0;
                  return Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        InkWell(
                          onTap: widget.product != Product.booking.index ? () => setState(() {
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return ProductPage(model);
                            }));
                          }) : null,
                          child: Row(
                            children: [
                              CustomImage.network(model.image!.url, width: 100, height: 160, fit: BoxFit.scaleDown),
                              Expanded(
                                child: Column(
                                  children: [
                                    if (rating > 0) Text(rating.toStringAsPrecision(2), style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black)),
                                    RatingBar.builder(
                                      initialRating: rating,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemSize: 16,
                                      itemPadding: EdgeInsets.zero,
                                      itemBuilder: (context, _) => Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      ignoreGestures: true,
                                      onRatingUpdate: (rating) async {},
                                    ),
                                    Text('${notice} ${AppLocalizations.of(context)!.text('reviews')}')
                                  ],
                                )
                              )
                            ],
                          )
                        ),
                        const SizedBox(height: 12),
                        Text(model.title!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
                        if (model.subtitle != null) Text(model.subtitle!, style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 4),
                        button(model)
                      ],
                    )
                  );
                }),
            );
          }
          return Center(child: CircularProgressIndicator(strokeWidth: 2.0, valueColor:AlwaysStoppedAnimation<Color>(Colors.black38)));
        }
      )
    );
  }
}