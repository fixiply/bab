import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/product_page.dart';
import 'package:bb/models/product_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/widgets/containers/abstract_container.dart';
import 'package:bb/widgets/custom_image.dart';

// External package
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:expandable_text/expandable_text.dart';

class ListContainer extends AbstractContainer {

  ListContainer({String? company, String? receipt, int? product}) : super(
    company: company,
    receipt: receipt,
    product: product
  );
  @override
  _ListContainerState createState() => _ListContainerState();
}


class _ListContainerState extends AbstractContainerState {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: FutureBuilder<List<ProductModel>>(
        future: products,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                ProductModel model = snapshot.data![index];
                double rating = ratings.containsKey(model.uuid) ? ratings[model.uuid]! : 0;
                int notice = notices.containsKey(model.uuid) ? notices[model.uuid]! : 0;
                return Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(model.title!, textAlign: TextAlign.left, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      if (model.subtitle != null) Text(model.subtitle!, style: const TextStyle(fontSize: 14)),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
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
                                  ),
                                  const SizedBox(height: 8),
                                  ExpandableText(
                                    model.text!,
                                    linkColor: Theme.of(context).primaryColor,
                                    expandText: AppLocalizations.of(context)!.text('show_more').toLowerCase(),
                                    collapseText: AppLocalizations.of(context)!.text('show_less').toLowerCase(),
                                    maxLines: 5,
                                  )
                                ],
                              )
                            )
                          ],
                        )
                      ),
                      const SizedBox(height: 4),
                      button(model)
                    ],
                  )
                );
              }
            );
          }
          return const Center(child: CircularProgressIndicator(strokeWidth: 2.0, valueColor:AlwaysStoppedAnimation<Color>(Colors.black38)));
        }
      )
    );
  }
}