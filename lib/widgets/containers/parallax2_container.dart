import 'package:flutter/material.dart';

// Internal package
import 'package:bab/controller/product_page.dart';
import 'package:bab/models/product_model.dart';
import 'package:bab/utils/app_localizations.dart';
import 'package:bab/widgets/containers/abstract_container.dart';
import 'package:bab/widgets/custom_image.dart';

// External package
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:parallax_animation/parallax_area.dart';

class Parallax2Container extends AbstractContainer {
  Parallax2Container({String? company, String? recipe, int? product}) : super(
      company: company,
      recipe: recipe,
      product: product
  );

  @override
  _Parallax2ContainerState createState() => _Parallax2ContainerState();
}

class ParallaxFlowDelegate extends FlowDelegate {
  ParallaxFlowDelegate({
    required this.scrollable,
    required this.listItemContext,
    required this.backgroundImageKey,
  }) : super(repaint: scrollable.position);


  final ScrollableState scrollable;
  final BuildContext listItemContext;
  final GlobalKey backgroundImageKey;

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return BoxConstraints.tightFor(
      width: constraints.maxWidth,
    );
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    // Calculate the position of this list item within the viewport.
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final listItemBox = listItemContext.findRenderObject() as RenderBox;
    final listItemOffset = listItemBox.localToGlobal(
        listItemBox.size.centerLeft(Offset.zero),
        ancestor: scrollableBox);

    // Determine the percent position of this list item within the
    // scrollable area.
    final viewportDimension = scrollable.position.viewportDimension;
    final scrollFraction =
    (listItemOffset.dy / viewportDimension).clamp(0.0, 1.0);

    // Calculate the vertical alignment of the background
    // based on the scroll percent.
    final verticalAlignment = Alignment(0.0, scrollFraction * 2 - 1);

    // Convert the background alignment into a pixel offset for
    // painting purposes.
    final backgroundSize =
        (backgroundImageKey.currentContext!.findRenderObject() as RenderBox)
            .size;
    final listItemSize = context.size;
    final childRect =
    verticalAlignment.inscribe(backgroundSize, Offset.zero & listItemSize);

    // Paint the background.
    context.paintChild(
      0,
      transform:
      Transform.translate(offset: Offset(0.0, childRect.top)).transform,
    );
  }

  @override
  bool shouldRepaint(ParallaxFlowDelegate oldDelegate) {
    return scrollable != oldDelegate.scrollable ||
        listItemContext != oldDelegate.listItemContext ||
        backgroundImageKey != oldDelegate.backgroundImageKey;
  }
}

class _Parallax2ContainerState extends AbstractContainerState {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 280,
        color: Colors.white,
        child: FutureBuilder<List<ProductModel>>(
          future: products,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                shrinkWrap: true,
                // physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data!.length,
                itemExtent: 280,
                itemBuilder: (context, index) {
                  ProductModel model = snapshot.data![index];
                  double rating = ratings.containsKey(model.uuid) ? ratings[model.uuid]! : 0;
                  int notice = notices.containsKey(model.uuid) ? notices[model.uuid]! : 0;
                  final GlobalKey _backgroundImageKey = GlobalKey();
                  return Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Flow(
                          delegate: ParallaxFlowDelegate(
                            scrollable: Scrollable.of(context),
                            listItemContext: context,
                            backgroundImageKey: _backgroundImageKey,
                          ),
                          children: [
                            InkWell(
                              onTap: widget.product != Product.booking.index ? () => setState(() {
                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  return ProductPage(model);
                                }));
                              }) : null,
                              child: Row(
                                key: _backgroundImageKey,
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
                          ],
                        ),

                        const SizedBox(height: 12),
                        Text(AppLocalizations.of(context)!.localizedText(model.title), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
                        if (model.subtitle != null) Text(AppLocalizations.of(context)!.localizedText(model.subtitle), style: const TextStyle(fontSize: 14)),
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