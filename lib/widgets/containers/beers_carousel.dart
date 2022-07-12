import 'package:flutter/material.dart';

// Internal package
import 'package:bb/models/beer_model.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/models/rating_model.dart';
import 'package:bb/utils/constants.dart';
import 'package:bb/widgets/custom_image.dart';
import 'package:bb/widgets/dialogs/text_input_dialog.dart';

// External package
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class BeersCarousel extends StatefulWidget {
  final String company;
  final String? title;
  BeersCarousel(this.company, {this.title});

  _BeersCarouselState createState() => new _BeersCarouselState();
}


class _BeersCarouselState extends State<BeersCarousel> {
  Future<List<BeerModel>>? _beers;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: FutureBuilder<List<BeerModel>>(
        future: _beers,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return CarouselSlider(
              options: CarouselOptions(
                height: 280,
                initialPage: 0,
                viewportFraction: 0.6,
                // enlargeCenterPage: true,
                // enlargeStrategy: CenterPageEnlargeStrategy.height,
              ),
              items: snapshot.data!.map((model) => Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      children: [
                        CustomImage.network(model.image!.url, width: 100, height: 160, fit: BoxFit.scaleDown),
                        Expanded(
                          child: Column(
                            children: [
                              if (model.rating() > 0) Text(model.rating().toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black)),
                              RatingBar.builder(
                                initialRating: model.rating(),
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
                                onRatingUpdate: (rating) async {
                                  // dynamic? text = await showDialog(
                                  //     context: context,
                                  //     builder: (BuildContext context) {
                                  //       return TextInputDialog(
                                  //           title: 'Qu\'en pensez-vous ?',
                                  //           maxLines: 3
                                  //       );
                                  //     }
                                  // );
                                  // if (text != false) {
                                  //   RatingModel newModel = RatingModel(
                                  //       creator: currentUser!.user!.uid,
                                  //       rating: rating
                                  //   );
                                  // }
                                },
                              ),
                              Text('${model.notice()} avis')
                            ],
                          )
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(model.title!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
                    if (model.subtitle != null) Text(model.subtitle!, style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 100,
                      child: TextButton(
                        style: TextButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Theme.of(context).primaryColor),
                        )),
                        child: Text('${model.price!.toStringAsPrecision(3)} €', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        onPressed: () {
                        },
                      )
                    ),
                  ],
                )
              )).toList(),
            );
          }
          return Center(child: CircularProgressIndicator(strokeWidth: 2.0, valueColor:AlwaysStoppedAnimation<Color>(Colors.black38)));
        }
      )
    );
  }

  _fetch() async {
    setState(() {
      _beers = Database().getBeers(company: widget.company, ordered: true);
    });
  }

  bool hasRating(BeerModel model) {
    return model.ratings != null && model.ratings!.length > 0;
  }

  double rating(BeerModel model) {
    double rating = 0;
    if (model.ratings != null) {
      for(RatingModel model in model.ratings!) {
        rating += model.rating!;
      }
      rating = rating / model.ratings!.length;
    }
    return rating;
  }
}