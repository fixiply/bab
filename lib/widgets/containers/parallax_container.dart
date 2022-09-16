import 'package:flutter/material.dart';

// Internal package
import 'package:bb/controller/beer_page.dart';
import 'package:bb/models/beer_model.dart';
import 'package:bb/models/rating_model.dart';
import 'package:bb/utils/app_localizations.dart';
import 'package:bb/utils/database.dart';
import 'package:bb/widgets/custom_image.dart';
import 'package:bb/widgets/modal_bottom_sheet.dart';

// External package
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:parallax_animation/parallax_area.dart';

class ParallaxContainer extends StatefulWidget {
  final String? company;
  final String? receipt;
  final String? title;
  ParallaxContainer({this.company, this.receipt, this.title});

  _ParallaxContainerState createState() => new _ParallaxContainerState();
}


class _ParallaxContainerState extends State<ParallaxContainer> {
  Future<List<BeerModel>>? _beers;
  Map<String, double> _ratings = Map<String, double>();
  Map<String, int> _notices = Map<String, int>();

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      color: Colors.white,
      child: FutureBuilder<List<BeerModel>>(
        future: _beers,
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
                  BeerModel model = snapshot.data![index];
                  double rating = _ratings.containsKey(model.uuid) ? _ratings[model.uuid]! : 0;
                  int notices = _notices.containsKey(model.uuid) ? _notices[model.uuid]! : 0;
                  return Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () => setState(() {
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return BeerPage(model);
                            }));
                          }),
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
                                    Text('${notices} ${AppLocalizations.of(context)!.text('reviews')}')
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
                        SizedBox(
                          width: 100,
                          child: TextButton(
                            child: Text('${model.price!.toStringAsPrecision(3)} €', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            style: TextButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, shape: RoundedRectangleBorder(
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
                }),
            );
          }
          return Center(child: CircularProgressIndicator(strokeWidth: 2.0, valueColor:AlwaysStoppedAnimation<Color>(Colors.black38)));
        }
      )
    );
  }

  _fetch() async {
    setState(() {
      _beers = Database().getBeers(company: widget.company, receipt: widget.receipt, ordered: true);
    });
    _calculate();
  }

  _calculate() async {
    List<BeerModel>? beers = await _beers;
    _notices.clear();
    _ratings.clear();
    if (beers != null && beers.length > 0) {
      for(BeerModel beer in beers) {
        double rating = 0;
        List<RatingModel>? ratings = await Database().getRatings(beer: beer.uuid);
        if (ratings != null && ratings.length > 0) {
          for (RatingModel model in ratings) {
            rating += model.rating!;
          }
          rating = rating / ratings.length;
        }
        setState(() {
          _notices[beer.uuid!] = ratings != null ? ratings.length : 0;
          _ratings[beer.uuid!] = rating;
        });
      }
    }
  }
}