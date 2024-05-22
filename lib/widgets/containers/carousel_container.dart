import 'package:bab/widgets/containers/abstract_container.dart';
import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/product_page.dart';
import 'package:bab/models/product_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/widgets/custom_image.dart';
import 'package:bab/widgets/modal_bottom_sheet.dart';

// External package
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CarouselContainer extends AbstractContainer {
  CarouselContainer({String? company, String? recipe, int? product}) : super(
      company: company,
      recipe: recipe,
      product: product
  );

  @override
  _CarouselContainerState createState() => _CarouselContainerState();
}


class _CarouselContainerState extends AbstractContainerState {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: FutureBuilder<List<ProductModel>>(
        future: products,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return Container();
            }
            return CarouselSlider(
              options: CarouselOptions(
                height: 280,
                initialPage: 0,
                viewportFraction: 0.6,
                enableInfiniteScroll: false
              ),
              items: snapshot.data!.map((model) {
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
                                  if (rating > 0) Text(rating.toStringAsPrecision(2), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black)),
                                  RatingBar.builder(
                                    initialRating: rating,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemSize: 16,
                                    itemPadding: EdgeInsets.zero,
                                    itemBuilder: (context, _) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    ignoreGestures: true,
                                    onRatingUpdate: (rating) async {},
                                  ),
                                  Text('$notice ${AppLocalizations.of(context)!.text('reviews')}')
                                ],
                              )
                            )
                          ],
                        )
                      ),
                      const SizedBox(height: 12),
                      Text(model.title!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
                      if (model.subtitle != null) Text(model.subtitle!, style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 100,
                        child: TextButton(
                          child: Text(AppLocalizations.of(context)!.currencyFormat(model.price) ?? '', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          style: TextButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Theme.of(context).primaryColor),
                          )),
                          onPressed: () {
                            ModalBottomSheet.showAddToCart(context, model);
                          },
                        )
                      ),
                    ],
                  )
                );
              }).toList(),
            );
          }
          return const Center(child: CircularProgressIndicator(strokeWidth: 2.0, valueColor:AlwaysStoppedAnimation<Color>(Colors.black38)));
        }
      )
    );
  }
}